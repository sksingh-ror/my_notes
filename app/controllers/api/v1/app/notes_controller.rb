class Api::V1::App::NotesController < ApplicationController
  before_action :authenticate_request
  before_action :set_note, only: [ :show, :update, :destroy ]

  # List all notes for the authenticated user
  def index
    notes = @current_user.notes
    render json: notes
  end

  # List paginated notes for the authenticated user
  def index
    notes = @current_user.notes.order(created_at: :desc)

    # Search by title or body
    if params[:query].present?
      notes = notes.where("title ILIKE :query OR body ILIKE :query", query: "%#{params[:query]}%")
    end

    # Filter by favorite status
    if params[:favorite].present?
      notes = notes.where(favorite: ActiveModel::Type::Boolean.new.cast(params[:favorite]))
    end

    # Custom Pagination
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    total_count = notes.count

    notes = notes.limit(per_page).offset((page - 1) * per_page)

    render json: {
      notes: notes,
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: (total_count.to_f / per_page).ceil,
        total_count: total_count
      }
    }
  end

  # Show a specific note
  def show
    render json: @note
  end

  # Create a new note
  def create
    note = @current_user.notes.new(note_params)
    if note.save
      render json: note, status: :created
    else
      render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Update a note
  def update
    if @note.update(note_params)
      render json: @note
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Delete a note
  def destroy
    @note.destroy
    render json: { message: "Note deleted successfully" }
  end

  private

  def set_note
    @note = @current_user.notes.find_by(id: params[:id])
    render json: { error: "Note not found" }, status: :not_found unless @note
  end

  def note_params
    params.permit(:title, :body, :favorite)
  end
end
