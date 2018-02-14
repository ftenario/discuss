defmodule DiscussWeb.AuthController do
    use DiscussWeb, :controller
    alias Discuss.Notes.User
    alias Discuss.Repo
    plug Ueberauth

    # conn is pattern match with the AUTH Object down below
    def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
        IO.puts "----------------"
        IO.inspect(params["provider"])
        IO.puts "----------------"

        user_params = %{token: auth.credentials.token, email: auth.info.email, provider: params["provider"]}
        changeset = User.changeset(%User{}, user_params)

        signin(conn, changeset)
    end

    def signout(conn, _params) do
        #unset the user id of the session
        conn 
        |> configure_session(drop: true)
        |> redirect(to: topic_path(conn, :index))
    end

    # figure out if the user is signed in
    defp signin(conn, changeset) do
        case insert_or_update_user(changeset) do
            # If we are successfult, return a conn with a flash message
            # and put a session using the user id
            {:ok, user} ->
                conn
                |> put_flash(:info, "Welcome back")
                |> put_session(:user_id, user.id)
                |> redirect(to: topic_path(conn, :index))
            #if there are errors, return the conn with a put_flash stating the error
            # an dthen redirect to index
            {:error, _reason} ->
                conn
                |> put_flash(:error, "Error signing in")
                |> redirect(to: topic_path(conn, :index))
        end
    end

    # Check if there is already a user in the users table with an email
    # that is in the changeset
    defp insert_or_update_user(changeset) do
        case Repo.get_by(User, email: changeset.changes.email) do
            nil -> 
                Repo.insert(changeset)
            user ->
                {:ok, user}
        end
    end

end

# AUTH Object
# %{ueberauth_auth: %Ueberauth.Auth{credentials: %Ueberauth.Auth.Credentials{expires: false,
#     expires_at: nil, other: %{}, refresh_token: nil,
#     scopes: ["public_repo", "user"], secret: nil,
#     token: "2bf5960f9a354986e9e3cd45c6c334bc8e8220b1", token_type: "Bearer"},
#    extra: %Ueberauth.Auth.Extra{raw_info: %{token: %OAuth2.AccessToken{access_token: "2bf5960f9a354986e9e3cd45c6c334bc8e8220b1",
#        expires_at: nil, other_params: %{"scope" => "public_repo,user"},
#        refresh_token: nil, token_type: "Bearer"},
#       user: %{"collaborators" => 0, "two_factor_authentication" => false,
#         "company" => nil,
#         "bio" => "A Polyglot Developer. Interests in Golang, Elixir, Python, C#, Javascript and some frameworks.",
#         "following" => 0,
#         "followers_url" => "https://api.github.com/users/ftenario/followers",
#         "public_gists" => 0, "id" => 7606560,
#         "avatar_url" => "https://avatars2.githubusercontent.com/u/7606560?v=4",
#         "events_url" => "https://api.github.com/users/ftenario/events{/privacy}",
#         "starred_url" => "https://api.github.com/users/ftenario/starred{/owner}{/repo}",
#         "emails" => [%{"email" => "ftenario@yahoo.com", "primary" => true,
#            "verified" => true, "visibility" => "public"}], "private_gists" => 0,
#         "blog" => "",
#         "subscriptions_url" => "https://api.github.com/users/ftenario/subscriptions",
#         "type" => "User", "disk_usage" => 5528, "site_admin" => false,
#         "owned_private_repos" => 0, "public_repos" => 17,
#         "location" => "Southern California", "hireable" => nil,
#         "created_at" => "2014-05-16T20:37:34Z", "name" => "LorenzoTech",
#         "organizations_url" => "https://api.github.com/users/ftenario/orgs",
#         "gists_url" => "https://api.github.com/users/ftenario/gists{/gist_id}",
#         "following_url" => "https://api.github.com/users/ftenario/following{/other_user}",
#         "url" => "https://api.github.com/users/ftenario", "email" => nil,
#         "login" => "ftenario", "html_url" => "https://github.com/ftenario",
#         "gravatar_id" => "",
#         "received_events_url" => "https://api.github.com/users/ftenario/received_events",
#         "repos_url" => "https://api.github.com/users/ftenario/repos",
#         "plan" => %{"collaborators" => 0, "name" => "free",
#           "private_repos" => 0, "space" => 976562499}, "followers" => 0,
#         "updated_at" => "2018-01-02T01:56:50Z", "total_private_repos" => 0}}},
#    info: %Ueberauth.Auth.Info{description: nil, email: "ftenario@yahoo.com",
#     first_name: nil,
#     image: "https://avatars2.githubusercontent.com/u/7606560?v=4",
#     last_name: nil, location: "Southern California", name: "LorenzoTech",
#     nickname: "ftenario", phone: nil,
#     urls: %{api_url: "https://api.github.com/users/ftenario",
#       avatar_url: "https://avatars2.githubusercontent.com/u/7606560?v=4",
#       blog: "",
#       events_url: "https://api.github.com/users/ftenario/events{/privacy}",
#       followers_url: "https://api.github.com/users/ftenario/followers",
#       following_url: "https://api.github.com/users/ftenario/following{/other_user}",
#       gists_url: "https://api.github.com/users/ftenario/gists{/gist_id}",
#       html_url: "https://github.com/ftenario",
#       organizations_url: "https://api.github.com/users/ftenario/orgs",
#       received_events_url: "https://api.github.com/users/ftenario/received_events",
#       repos_url: "https://api.github.com/users/ftenario/repos",
#       starred_url: "https://api.github.com/users/ftenario/starred{/owner}{/repo}",
#       subscriptions_url: "https://api.github.com/users/ftenario/subscriptions"}},
#    provider: :github, strategy: Ueberauth.Strategy.Github, uid: 7606560}}
