class Admin::FreelancersController < Admin::BaseController
  include LoginAs

  before_action :set_freelancer, only: [:show, :edit, :update, :destroy, :enable, :disable, :login_as]

  def index
    @keywords = params.dig(:search, :keywords).presence

    @freelancers = Freelancer.order(:name)
    if @keywords
      @freelancers = @freelancers.search(@keywords)
    end
    @freelancers = @freelancers.page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    if @freelancer.update(freelancer_params)
      redirect_to admin_freelancer_path(@freelancer), notice: "Freelancer updated."
    else
      render :edit
    end
  end

  def destroy
    @freelancer.destroy
    redirect_to admin_freelancers_path, notice: "Freelancer removed."
  end

  def enable
    @freelancer.enable!
    redirect_to admin_freelancers_path, notice: "Freelancer enabled."
  end

  def disable
    @freelancer.disable!
    redirect_to admin_freelancers_path, notice: "Freelancer disabled."
  end

  private

    def set_freelancer
      @freelancer = Freelancer.find(params[:id])
    end

    def freelancer_params
      # params.fetch(:freelancer, {})
      params.require(:freelancer).permit(
        :name, 
        :email, 
        :verified,
        :address,
        :area,
        :tagline,
        :bio,
        :keywords,
        :skills,
        :years_of_experience,
        :available,
        :verified,
        :avatar,
        :pay_unit_time_preference
      )

    end

end
