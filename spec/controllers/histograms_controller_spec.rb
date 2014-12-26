require_relative '../helpers'

describe HistogramsController do
  RSpec.configure do |c|
    c.include Helpers
  end

  before(:each) do
    username = FactoryGirl.attributes_for(:histogram)[:username]
    stub_info_request(username)
    stub_photo_request(username)
  end

  describe "GET index" do
    it "assigns @histograms" do
      histogram = FactoryGirl.create(:histogram)
      get :index
      expect(assigns(:histograms)).to eq [histogram]
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET #show" do
    it "assigns the requested histogram to @histogram" do
      histogram = FactoryGirl.create(:histogram)
      get :show, id: histogram
      expect(assigns(:histogram)).to eq histogram
    end

    it "renders the show template" do
      get :show, id: FactoryGirl.create(:histogram)
      expect(response).to render_template :show
    end
  end

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template :new
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      let(:new_hist) { FactoryGirl.attributes_for(:histogram) }

      it "creates a new histogram" do
        expect {
          post :create, histogram: new_hist
        }.to change(Histogram, :count).by(1)
      end

      it "redirects to the new histogram" do
        post :create, histogram: new_hist
        expect(response).to redirect_to assigns(:histogram)
      end

      context "with existing username" do
        before(:each) do
          post :create, histogram: new_hist
        end

        it "does not create a new histogram" do
          expect {
            post :create, histogram: new_hist
          }.to_not change(Histogram, :count)
        end

        it "redirects to the existing histogram page" do
          post :create, histogram: new_hist
          username = new_hist[:username]
          expect(response).to redirect_to Histogram.find_by(username: username)
        end
      end
    end

    context "with invalid attributes" do
      let(:bad_hist) { FactoryGirl.attributes_for(:invalid_histogram) }

      before(:each) do
        stub_info_request_undefined_user(bad_hist[:username])
      end

      it "does not save the new histogram" do
        expect {
          post :create, histogram: bad_hist
        }.to_not change(Histogram, :count)
      end

      it "re-renders the new method" do
        post :create, histogram: bad_hist
        expect(response).to render_template :new
      end
    end
  end

  describe "POST #pull" do
    before(:each) do
      @histogram = FactoryGirl.create(:histogram)
    end

    it "pulls the next #{Helpers::TEST_PULL_LIMIT*2} posts for @histogram" do
      post :pull, id: @histogram
      @histogram.reload

      expect(@histogram.offset).to be Helpers::TEST_PULL_LIMIT * 2
    end

    it "updates the histogram with new data" do
      original_histogram = @histogram.histogram

      post :pull, id: @histogram
      @histogram.reload

      @histogram.histogram.each do |color, size|
        expect(size).to eq (original_histogram[color] * 2)
      end
    end

    it "redirects to the updated @histogram" do
      post :pull, id: @histogram
      expect(response).to redirect_to @histogram
    end
  end
end

