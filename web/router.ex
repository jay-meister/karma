defmodule Karma.Router do
  use Karma.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Karma.Auth, repo: Karma.Repo
  end

  # pipeline :api do
  #   plug :accepts, ["json"]
  # end

  scope "/", Karma do
    pipe_through :browser # Use the default browser stack
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/verification/:hash", VerificationController, :verify
    get "/verification/verify/:hash", VerificationController, :verify_again
    get "/verification/resend/:hash", VerificationController, :resend
    get "/", DashboardController, :index
  end

  # authed routes
  scope "/", Karma do
    pipe_through [:browser, :authenticate]
    resources "/projects", ProjectController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Karma do
  #   pipe_through :api
  # end
end
