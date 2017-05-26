class Company::Postings::JobsController < Company::BaseController
  before_action :set_job, only: [:show, :edit, :update, :destroy, :contract, :edit_contract, :update_contract]

  def new
    @job = Job.new(project_id: params[:project_id])
  end

  def create
    @job = Job.new(job_params)

    validate_ownership
    if @job.errors.size > 0
      render :new
      return
    end

    @job.published = true if job_params[:published]

    if @job.save
      redirect_to company_postings_job_path(@job), notice: "Job created."
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    validate_ownership
    if @job.errors.size > 0
      render :edit
      return
    end

    if @job.update(job_params)
      redirect_to company_postings_job_path(@job), notice: "Job updated."
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to company_postings_projects_path, notice: "Job removed."
  end


  private

    def set_job
      @job = Job.find(params[:id])
      unless @job.project.company_id == current_company.id
        redirect_to company_postings_projects_path, error: "Invalid project selected."
      end
    end

    def validate_ownership
      unless job_params[:project_id].present? && current_company.projects.find(job_params[:project_id])
        @job.errors[:project_id] << "Invalid project selected"
      end
    end

    def job_params
      params.require(:job).permit(
        :project_id,
        :title,
        :summary,
        :scope_of_work,
        :budget,
        :job_function,
        :pay_type,
        :starts_on,
        :duration,
        :freelancer_type,
        :keywords,
        :invite_only,
        :scope_is_public,
        :budget_is_public,
        :state
      )
    end
end