defmodule Changelog.Admin.EpisodeController do
  use Changelog.Web, :controller

  alias Changelog.Podcast
  alias Changelog.Episode

  plug :assign_podcast

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply __MODULE__, action_name(conn), arg_list
  end

  def index(conn, _params, podcast) do
    episodes = Repo.all from e in Episode, where: e.podcast_id == ^podcast.id
    render conn, "index.html", episodes: episodes
  end

  def new(conn, _params, podcast) do
    changeset =
      build_assoc(podcast, :episodes)
      |> Episode.changeset
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"episode" => episode_params}, podcast) do
    changeset =
      build_assoc(podcast, :episodes)
      |> Episode.changeset(episode_params)

    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_flash(:info, "#{episode.title} created!")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => id}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get!(id)
    changeset = Episode.changeset(episode)
    render conn, "edit.html", episode: episode, changeset: changeset
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get! Podcast, conn.params["podcast_id"]
    assign conn, :podcast, podcast
  end
end
