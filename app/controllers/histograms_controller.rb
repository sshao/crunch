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
    if (params[:histogram][:source_ts])
      params[:histogram][:source_ts] = DateTime.strptime(params[:histogram][:source_ts], "%s")
    end

    @histogram = Histogram.new(permitted_params(params))
    if @histogram.save
      redirect_to @histogram
    else
      if Histogram.exists?(:username => params[:histogram][:username])
        redirect_to Histogram.find_by(username: params[:histogram][:username])
      else
        flash[:error] = @histogram.errors.full_messages
        render :action => :new
      end
    end
  end

  def pull
    histogram = Histogram.find(params[:id])
    histogram.update_histogram
    histogram.save
    redirect_to histogram
  end

  def permitted_params(params)
    params.require(:histogram).permit(:username, :source_ts)
  end

  def permitted_update_params
    {}
  end
end
