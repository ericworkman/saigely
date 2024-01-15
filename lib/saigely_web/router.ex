defmodule SaigelyWeb.Router do
  use SaigelyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SaigelyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SaigelyWeb do
    pipe_through :browser

    live "/", PostLive.Index, :index

    live "/characters", CharacterLive.Index, :index
    live "/characters/new", CharacterLive.Index, :new
    live "/characters/:username/edit", CharacterLive.Index, :edit
    live "/characters/:username", CharacterLive.Show, :show
    live "/characters/:username/show/edit", CharacterLive.Show, :edit

    live "/posts", PostLive.Index, :index
    live "/posts/new", PostLive.Index, :new
    live "/posts/:id/edit", PostLive.Index, :edit
    live "/posts/:id", PostLive.Show, :show
    live "/posts/:id/show/edit", PostLive.Show, :edit

    live "/logs", LogLive.Index, :index
    live "/logs/new", LogLive.Index, :new
    live "/logs/:id/edit", LogLive.Index, :edit
    live "/logs/:id", LogLive.Show, :show
    live "/logs/:id/show/edit", LogLive.Show, :edit

    live "/comments", CommentLive.Index, :index
    live "/comments/new", CommentLive.Index, :new
    live "/comments/:id/edit", CommentLive.Index, :edit
    live "/comments/:id", CommentLive.Show, :show
    live "/comments/:id/show/edit", CommentLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", SaigelyWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:saigely, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SaigelyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
