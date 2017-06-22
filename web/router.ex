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
    resources "/password", PasswordController, only: [:new, :create, :edit, :update]
    get "/", DashboardController, :index
  end

  # authed routes
  scope "/", Karma do
    pipe_through [:browser, :authenticate]
    post "/startpack/:id", StartpackController, :update
    resources "/startpack", StartpackController, except: [:new, :create]
    resources "/projects", ProjectController do
      resources "/documents", DocumentController do
        get "/signees/new", SigneeController, :add
        post "/signees/new", SigneeController, :add_signee
        delete "/signees", SigneeController, :clear_signees
      end
      resources "/signees", SigneeController, only: [:create, :delete]

      resources "/offers", OfferController do
        # project_offer_altered_document_path(conn, project, offer, alt_doc)
        # /projects/:project_id/offers/:offer_id/altered_documents/:id/sign
        get "altered_documents/:id/sign", AlteredDocumentController, :sign
      end
      put "/offers/:id/response", OfferController, :response
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Karma do
  #   pipe_through :api
  # end
end
