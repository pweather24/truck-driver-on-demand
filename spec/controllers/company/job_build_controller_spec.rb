require "rails_helper"

RSpec.describe Company::JobBuildController, type: :controller do
  login_company
  let(:company) { subject.current_user.company }
  let(:job) { create(:job, company: company, project: create(:project, company: company), creator: company.owner) }

  describe "GET #show" do
    describe "step: job_details" do
      it "renders job_details template" do
        get :show, params: { id: :job_details, job_id: job.id }
        expect(response).to render_template('company/job_build/job_details')
      end
    end

    describe "step: candidate_details" do
      let!(:job) { create(:job, company: company, project: create(:project, company: company), creation_step: "candidate_details", creator: company.owner) }

      it "renders candidate_details template" do
        get :show, params: { id: :candidate_details, job_id: job.id }
        expect(response).to render_template('company/job_build/candidate_details')
      end
    end

    describe "step: wicked_finish" do
      context "when creation_step is wicked_finish" do
        let!(:job) { create(:job, company: company, project: create(:project, company: company), creation_step: "wicked_finish", creator: company.owner) }

        it "redirects to job" do
          get :show, params: { id: :wicked_finish, job_id: job.id }
          expect(response).to redirect_to(company_job_path(job))
        end
      end
    end
  end

  describe "PUT #update" do

    describe "step: job_details" do
      context "when the fields are filled" do
        let(:project) { create(:project, company: company) }
        let(:job_params) do
          {
            project_id: project.id,
            title: "Title",
            starts_on: Date.today,
            duration: 10,
            summary: "Summary",
            scope_of_work: "Scope",
            country: "es",
            address: "Madrid",
            budget: 5000,
            currency: "EUR"
          }
        end

        before do
          put :update, params: { id: :job_details, job_id: job.id, job: job_params }
        end

        it "creates a job with given attributes" do
          expect(company.jobs.last).to have_attributes(job_params)
        end

        it "redirects to next step path" do
          expect(response).to redirect_to(company_job_job_build_path(:candidate_details, job_id: job.id))
        end
      end

      context "when the fields are not filled" do
        let(:job_params) do
          {
            project_id: nil,
            title: "",
            starts_on: nil,
            duration: nil,
            summary: "",
            scope_of_work: "",
            country: "",
            address: "",
            budget: nil,
            currency: ""
          }
        end

        it "does not update the job" do
          put :update, params: { id: :job_details, job_id: job.id, job: job_params }
          job.reload
          expect(job.title).not_to eq("")
        end
      end
    end

    describe "step :candidate_details" do
      let!(:job) { create(:job,
                          company: company,
                          project: create(:project, company: company),
                          state: "created",
                          creation_step: "candidate_details",
                          job_type: 'system_integration',
                          job_market: 'type',
                          job_function: 'type',
                          starts_on: Date.today,
                          scope_of_work: 'Scope',
                          pay_type: 'fixed',
                          creator: company.owner,
                          budget: 10000) }
      let(:job_params) { job.attributes }

      before do
        put :update, params: { id: :candidate_details, job_id: job.id, job: job_params }
      end

      it "publishes the job" do
        expect(job.reload.state).to eq("published")
      end
    end
  end
end
