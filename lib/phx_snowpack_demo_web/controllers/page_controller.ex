defmodule PhxSnowpackDemoWeb.PageController do
  use PhxSnowpackDemoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
