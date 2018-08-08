class Company::JobBuildController < Company::BaseController

  include Wicked::Wizard

  before_action :set_job, except: [:index, :create]
  before_action :authorize_job, except: [:index, :create]

  steps :job_details, :candidate_details

  def index
    redirect_to company_job_step_path(:job_details)
  end

  def show
    if params[:id] == "wicked_finish"
      redirect_to finish_wizard_path
    else
      render_wizard
    end
  end

  def update
    @job.attributes = job_params
    @job.creation_step = next_step

    @job.state = "published" if @job.creation_completed? && (@job.save_draft == "false" || @job.save_draft.blank?)
    flash[:notice] = "You need to publish this job in order to make it visible to freelancers" if @job.creation_completed? && @job.save_draft == "true"

    render_wizard @job
  end

  def create
    @job = current_company.jobs.create
    @job.update_attribute(:creation_step, steps.first)
    authorize_job
    redirect_to wizard_path(steps.first, job_id: @job.id)
  end

  private

  def finish_wizard_path
    company_job_path(@job)
  end

  def set_job
    @job = current_company.jobs.find(params[:job_id])
  end

  def authorize_job
    authorize @job
  end

  def job_params
    params.require(:job).permit(
        :project_id,
        :title,
        :summary,
        :scope_of_work,
        :scope_file,
        :budget,
        :country,
        :currency,
        :job_type,
        :job_market,
        :job_function,
        :pay_type,
        :starts_on,
        :duration,
        :freelancer_type,
        :invite_only,
        :scope_is_public,
        :budget_is_public,
        :state,
        :address,
        :state_province,
        :save_draft,
        attachments_attributes: [:id, :file, :title, :_destroy],
        technical_skill_tags:  I18n.t("enumerize.technical_skill_tags").keys,
        manufacturer_tags:  I18n.t("enumerize.manufacturer_tags").keys,
    )
  end
end