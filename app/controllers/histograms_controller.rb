class HistogramsController < ApplicationController
  def index
    @histograms = Histogram.all
  end

  def show
    @histogram = Histogram.find(params[:id])
  end

  def new
  end

  def create
    # FIXME hack to convert epoch time to datetime ... 
    # it's here bc i can't figure out how to get this 
    # into the model
    params[:histogram][:source_ts] = DateTime.strptime(params[:histogram][:source_ts], "%s")
    
    @histogram = Histogram.new(permitted_params(params))
    if @histogram.save
      redirect_to @histogram
    else
      render :action => :new
    end
  end

  def permitted_params(params)
    params.require(:histogram).permit(:username, :histogram, :source_ts, :dataset_size)
  end
end
