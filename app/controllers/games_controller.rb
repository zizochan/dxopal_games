class GamesController < ApplicationController
  before_action :set_game_config, only: [:show, :source]

  def index
    @games = Global.game.to_hash.keys
  end

  def show
  end

  def source
    source_path = "app/dxopal/#{@game_id}.rb"
    raise "not found #{@game_id}" unless File.exists?(source_path)

    source = File.open(source_path).read
    render json: source
  end

  private

    def set_game_config
      @game_id = params[:id]
      @config  = Global.game[@game_id]

      raise "not found #{@game_id}" if @config.nil?
    end
end
