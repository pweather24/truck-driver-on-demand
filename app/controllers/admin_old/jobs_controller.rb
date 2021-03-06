# frozen_string_literal: true

class Admin::JobsController < Admin::BaseController

  before_action :set_job, only: %i[show edit update destroy driver_matches mark_as_expired unmark_as_expired]
  before_action :authorize_job, only: %i[show edit update destroy driver_matches mark_as_expired unmark_as_expired]

  def index
    authorize current_user
    @keywords = params.dig(:search, :keywords).presence
    @jobs = Job.order(created_at: :desc)
    @jobs = @jobs.search(@keywords) if @keywords
    @jobs = @jobs.page(params[:page])
  end

  def show
    if @job.state == "published"
      get_matches
      @repliers = @job.repliers
    else
      @drivers = Driver.none
      @repliers = Driver.none
    end
    @drivers = @drivers.page(params[:page]).per(10)
  end

  def edit
    @company = @job.company
  end

  def update
    @company = @job.company
    if @job.update(job_params)
      if params.dig(:job, :state) == "published"
        flash[:notice] = "This job has been published."
        get_matches
        @drivers.each do |driver|
          Notification.create(title: @job.title,
                              body: "New job in your area",
                              authorable: @job.company,
                              receivable: driver,
                              url: driver_job_url(@job))
          JobNotificationMailer.notify_job_posting(driver, @job).deliver_later
        end
      end
      redirect_to admin_job_path(@job), notice: "Job updated."
    else
      render :edit
    end
  end

  def destroy
    @job.destroy
    redirect_to admin_jobs_path, notice: "Jobs removed."
  end

  def driver_matches
    get_matches
  end

  def mark_as_expired
    @job.update_columns(expired: true)
    redirect_to admin_jobs_path, notice: "Job marked as expired."
  end

  def unmark_as_expired
    @job.update_columns(expired: false)
    redirect_to admin_jobs_path, notice: "Job marked as not expired."
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def authorize_job
    authorize @job
  end

  # rubocop:disable Metrics/MethodLength
  def job_params
    params.require(:job).permit(
      :title,
      :state,
      :summary,
      :scope_of_work,
      :scope_file,
      :budget,
      :job_type,
      :job_market,
      :job_function,
      :starts_on,
      :ends_on,
      :duration,
      :pay_type,
      :driver_type,
      :invite_only,
      :scope_is_public,
      :budget_is_public,
      :contract_price,
      :reporting_frequency,
      :require_photos_on_updates,
      :require_checkin,
      :require_uniform,
      :state_province,
      technical_skill_tags: I18n.t("enumerize.technical_skill_tags").keys,
      manufacturer_tags: I18n.t("enumerize.manufacturer_tags").keys,
    )
  end
  # rubocop:enable Metrics/MethodLength

end
