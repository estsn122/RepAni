class Admin::Animes::EpisodesController < Admin::BaseController
  def edit
    @anime = Anime.find(params[:anime_id])
  end

  def update
    @anime = Anime.find(params[:anime_id])
    if params.key?(:anime) && @anime.update(episodes_params)
      redirect_to admin_anime_path(@anime), success: 'エピソードを更新しました'
    else
      flash.now[:danger] = '更新に失敗しました'
      render :edit
    end
  end

  def destroy
    @episode = Episode.find(params[:id])
    @episode.destroy
  end

  private

  def episodes_params
    params.require(:anime).permit(episodes_attributes: %i[id num subtitle air_time broadcast_datetime public _destroy])
  end
end
