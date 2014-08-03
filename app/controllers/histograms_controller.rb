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
        render :action => :new
      end
    end
  end

  def update_ui_and_perform_next(ui_feedback, next_action)
    @ui_feedback = ui_feedback
    @next_action = next_action

    respond_to do |format|
      format.js {render layout: false}
    end
  end

  def pull
    loop_counter = params[:counter].to_i
    if loop_counter <= 0
      update_ui_and_perform_next("", nil)
    else
      histogram = Histogram.find(params[:id])
      cur_offset = histogram.offset
      histogram.update_histogram(5)
      histogram.save
      diff = histogram.offset - cur_offset

      # no more photo posts!!
      if diff == 0
        update_ui_and_perform_next("no more photo posts", nil)
      else
        update_ui_and_perform_next("#{loop_counter} left", "#{params[:id]}/#{loop_counter - diff}/pull")
      end
    end
  end

  def permitted_params(params)
    params.require(:histogram).permit(:username, :source_ts)
  end

  def permitted_update_params
    {}
  end
end
