class Company::MessagesController < Company::BaseController
  before_action :set_job

  def index
    set_collection
  end

  def create
    @message = @job.messages.new(message_params)
    @message.authorable = current_company

    if @message.save
      CompanyMailer.notice_message_sent(current_company, @job.freelancer, @message).deliver
      FreelancerMailer.notice_message_received(current_company, @job.freelancer, @job, @message).deliver
      redirect_to company_job_messages_path(@job)
    else
      set_collection
      render :show
    end
  end

  private

    def set_job
      @job = current_company.jobs.includes(messages: :authorable).find(params[:job_id])
    end

    def set_collection
      @messages = @job.messages
    end

    def message_params
      params.require(:message).permit(:body, :attachment)
    end
end