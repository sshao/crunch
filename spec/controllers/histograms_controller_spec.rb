require 'rails_helper'
require_relative '../helpers'

describe HistogramsController do
  RSpec.configure do |c|
    c.include Helpers
  end

  before(:each) do
    username = FactoryGirl.attributes_for(:histogram)[:username]
    stub_info_request(username)
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
      it "creates a new histogram" do
        expect {
          post :create, histogram: FactoryGirl.attributes_for(:histogram)
        }.to change(Histogram, :count).by(1)
      end

      it "redirects to the new histogram" do
        post :create, histogram: FactoryGirl.attributes_for(:histogram)
        expect(response).to redirect_to assigns(:histogram)
      end
    end

    context "with invalid attributes" do
      before(:each) do
        stub_info_request_undefined_user(FactoryGirl.attributes_for(:invalid_histogram)[:username])
      end

      it "does not save the new histogram" do
        expect {
          post :create, histogram: FactoryGirl.attributes_for(:invalid_histogram)
        }.to_not change(Histogram, :count)
      end

      it "re-renders the new method" do
        post :create, histogram: FactoryGirl.attributes_for(:invalid_histogram)
        expect(response).to render_template :new
      end
    end
  end
end

