class EmployeesController < ApplicationController
  before_action :set_employee_service, only: %i[edit show update]

  def index
    @employees = EmployeeService.new.fetch_all(params[:page])
  end

  def edit
    @employee = @employee_service.fetch(params[:id])
  end

  def show
    @employee = @employee_service.fetch(params[:id])
  end

  def create
    @employee = EmployeeService.new.create(employee_params)
    redirect_to employee_path(@employee["id"]), notice: "Employee created successfully."
  end

  def update
    @employee = @employee_service.update(params[:id], employee_params)
    redirect_to edit_employee_path(@employee["id"]), notice: "Employee updated successfully."
  end

  private

  def set_employee_service
    @employee_service = EmployeeService.new
  end

  def employee_params
    params.permit(:name, :position, :date_of_birth, :salary)
  end
end
