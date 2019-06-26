class GameController < ApplicationController
  def index
  end

  def tamayoke_source
    file   = File.open('app/dxopal/tamayoke.rb')
    source = file.read
    render json: source
  end
end
