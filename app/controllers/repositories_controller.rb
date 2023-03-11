class RepositoriesController < ApplicationController
  rescue_from RepositoriesError, with: :render_with_error

  def index
    @repos, @next_page = GithubRepositoriesService.call(query: params[:q], page: params[:page])
  end

  private

  def render_with_error
    @error = 'Unable to fetch repositories'
    render :index
  end
end
