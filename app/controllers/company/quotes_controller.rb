class Company::QuotesController < Company::BaseController
  before_action :set_applicant
  before_action :set_quote, only: [:accept, :decline]

  def index
    set_collections
  end

  def create
    set_collections

    if !params[:message][:status].nil?
      @status = params[:message][:status]
      params[:message].delete :status
    else
      @status = ""
    end

    @message = @applicant.messages.new({ body: params[:message][:body], attachment: params[:message][:attachment] })
    @message.authorable = current_company

    if @message.save
      if @status == "accept"
        @quotes.last.accept!
        @applicant.accept!
        self.send_decline_message
        redirect_to company_job_work_order_path(@job)
        @job.state = "negotiated"
        @job.save
        return
      elsif @status == "decline"
        @applicant.reject!
        @quotes.last.decline!
      elsif @status == "negotiate"
        # not sure what goes here.
        # either add a new quote, or add a counter offer somehow. NOT SURE.

        # decline previous quotes
        @quotes.each do |quote|
          quote.state = "declined"
          quote.save
        end

        if @quotes.count > 0
          @new_quote = @quotes.last.dup
        else
          @new_quote = Quote.new
        end
        
        @new_quote.author_type = "company"
        
        if params[:message][:counter_type] == "fixed"
          @new_quote.amount = params[:message][:counter]
        elsif params[:message][:counter_type] == "hourly"
          @new_quote.hourly_rate = params[:message][:counter_hourly_rate]
          @new_quote.number_of_hours = params[:message][:counter_number_of_hours]
          @new_quote.amount = params[:message][:counter_hourly_rate].to_i * params[:message][:counter_number_of_hours].to_i
        elsif params[:message][:counter_type] == "daily"
          @new_quote.daily_rate = params[:message][:counter_daily_rate]
          @new_quote.number_of_days = params[:message][:counter_number_of_days]
          @new_quote.amount = params[:message][:counter_daily_rate].to_i * params[:message][:counter_number_of_days].to_i
        end


        @new_quote.pay_type = params[:message][:counter_type]
        @new_quote.state = "pending"
        @new_quote.save
        
        if @quotes.count == 0
          @applicant.quotes << @new_quote
        end

      end

      redirect_to company_job_applicant_quotes_path(@job, @applicant)
    else
      set_collections
      render :index
    end
  end

  def send_decline_message
    set_collections
    @applicants.each do |applicant|
      if applicant.state != "declined" and applicant.state != "accepted"
        # send message
        message = Message.new
        message.authorable = current_company
        message.receivable = applicant
        message.body = "We have decided to go with another provider. Thanks for your interest!"
        message.save

        # update quote to be declined
        applicant.state = "declined"
        applicant.save
      end
    end
  end

  def accept
    @quote.accept!
    redirect_to company_job_applicant_quotes_path(@job, @applicant)
  end

  def decline
    @quote.decline!
    redirect_to company_job_applicant_quotes_path(@job, @applicant)
  end

  private

    def set_job
      @job = current_company.jobs.includes(applicants: [:quotes, :messages]).find(params[:job_id])
    end

    def set_applicant
      set_job
      if params[:applicant_id]
        @applicant = @job.applicants.find(params[:applicant_id])
      else
        @applicant = @job.applicants.without_state(:ignored).includes(:messages).order("messages.created_at").first
      end
    end

    def set_quote
      @quote = @applicant.quotes.find(params[:id])
    end

    def set_collections
      @messages = @applicant.messages
      @quotes = @applicant.quotes
      @all_quotes = @applicant.job.quotes
      @applicants = @applicant.job.applicants.without_state(:ignored)
      @combined_items = []
      @harmonized_items = []
      @harmonized_indices = []

      if @applicants.where({state: "accepted"}).length > 0
        @applicant_accepted = true
      else
        @applicant_accepted = false
      end

      @messages.each do |message|
        @combined_items.push({ type: "message", payload: message, date: message.created_at.to_i })
        @harmonized_indices.push(message.created_at.to_i)
      end

      @quotes.each do |quote|
        @combined_items.push({ type: "quote", payload: quote, date: quote.created_at.to_i })
        @harmonized_indices.push(quote.created_at.to_i)
      end

      @harmonized_indices = @harmonized_indices.sort.reverse()

      @harmonized_indices.each do |index|
        search_in_combined(@combined_items, index)
      end

      if params[:filter].presence
        @applicants = @applicants.where({state: params[:filter]})
      end

      @current_applicant_id = @applicant.id

    end

    def search_in_combined(haystack, needle)
      index = 0
      haystack.each do |item|
        if needle == item[:date]
          @harmonized_items.push(item)
          haystack.delete_at(index)
          return
        end
        index += 1
      end
    end

    def message_params
      params.require(:message).permit(:body, :attachment)
    end
end
