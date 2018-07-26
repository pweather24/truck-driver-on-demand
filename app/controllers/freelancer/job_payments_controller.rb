class Freelancer::JobPaymentsController < Freelancer::BaseController
  before_action :set_job
  before_action :set_payment, except: [:index, :create_payment]
  before_action :authorize_job

  def index
    # @job = Job.find(params[:job_id])
    @payments = @job.payments.order(:created_at)
    @connector = StripeAccount.new(current_user)
  end

  def show
  end

  def print
    render layout: false
  end

  def request_payout
    # payment = Payment.find(params[:payment_id])
    @payment.issued_on = Date.today
    @payment.save
    # Send notice email
    PaymentsMailer.request_payout_company(@job.company, current_user, @job, @payment).deliver_later
    redirect_to freelancer_job_payments_path(job_id: @job.id)
  end

  def create_payment
    binding.pry
    @payment = @job.payments.build(payment_params)
    @payment.issued_on = Date.today
    @payment.tax_amount = @payment.amount * (@job.applicable_sales_tax/100)
    @payment.total_amount = @payment.amount + @payment.tax_amount
    @payment.set_avj_fees
    @payment.set_avj_credit
    if @payment.save
      redirect_to freelancer_job_payments_path(@job)
    else
      flash[:error] = @payment.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  private
  def set_job
    @job = current_user.jobs.includes(:payments).find(params[:job_id])
  end

  def set_payment
    @payment = @job.payments.find(params[:id])
  end

  def authorize_job
    authorize @job
  end

  def payment_params
    params.require(:payment).permit(
      :company_id,
      :description,
      :amount
    )
  end
end
