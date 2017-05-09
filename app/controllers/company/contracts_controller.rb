class Company::ContractsController < Company::BaseController
  before_action :set_job

  def show
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to company_job_contract_path(@job), notice: "Contract updated."
    else
      render :edit
    end
  end


  private

    def job_params
      params.require(:job).permit(
        :summary,
        :scope_of_work,
        :budget,
        :job_function,
        :starts_on,
        :duration,
        :pay_type,
        :freelancer_type,
        :state
      )
    end
end
