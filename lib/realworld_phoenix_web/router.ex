defmodule RealworldPhoenixWeb.Router do
  use RealworldPhoenixWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug Guardian.Plug.Pipeline,
      module: RealworldPhoenix.Guardian,
      error_handler: RealworldPhoenixWeb.AuthErrorHandler

    plug :accepts, ["json"]
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.VerifyHeader, scheme: "Token"
  end

  pipeline :check_authenticated do
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  pipeline :require_authenticated do
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  scope "/", RealworldPhoenixWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # required Authenticated
  scope "/api", RealworldPhoenixWeb do
    pipe_through [:api, :require_authenticated]

    get "/user", UserController, :show
    put "/user", UserController, :update

    post "/articles", ArticleController, :create
    get "/articles/feed", ArticleController, :feed

    put "/articles/:slug", ArticleController, :update
    delete "/articles/:slug", ArticleController, :delete

    post "/articles/:slug/comments", CommentController, :create
    delete "/articles/:slug/comments/:id", CommentController, :delete

    post "/profiles/:username/follow", ProfileController, :follow
    delete "/profiles/:username/follow", ProfileController, :unfollow

    post "/articles/:slug/favorite", FavoriteController, :create
    delete "/articles/:slug/favorite", FavoriteController, :delete
  end

  # Not required Authenticated
  scope "/api", RealworldPhoenixWeb do
    pipe_through [:api, :check_authenticated]

    get "/articles", ArticleController, :index
    get "/articles/:slug", ArticleController, :show
    get "/articles/:slug/comments", CommentController, :list

    post "/users/login", UserController, :login
    post "/users", UserController, :create

    get "/profiles/:username", ProfileController, :show

    get "/tags", TagController, :index
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RealworldPhoenixWeb.Telemetry
    end
  end
end
