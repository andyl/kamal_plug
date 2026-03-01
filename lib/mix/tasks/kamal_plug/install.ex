defmodule Mix.Tasks.KamalPlug.Install do
  use Igniter.Mix.Task

  # Adds KamalPlug.HealthCheck to your Phoenix endpoint

  @impl Igniter.Mix.Task
  def info(_argv, _composing_task) do
    %Igniter.Mix.Task.Info{
      group: :kamal_plug,
      example: "mix kamal_plug.install"
    }
  end

  @impl Igniter.Mix.Task
  def igniter(igniter) do
    {igniter, endpoint} = Igniter.Libs.Phoenix.select_endpoint(igniter)

    if endpoint do
      Igniter.Project.Module.find_and_update_module!(igniter, endpoint, fn zipper ->
        if already_installed?(zipper) do
          {:ok, zipper}
        else
          {:ok, add_health_check_plug(zipper)}
        end
      end)
    else
      Igniter.add_warning(igniter, "No Phoenix endpoint found")
    end
  end

  defp already_installed?(zipper) do
    case Igniter.Code.Function.move_to_function_call_in_current_scope(
           zipper,
           :plug,
           [1, 2],
           &health_check_plug?/1
         ) do
      {:ok, _} -> true
      :error -> false
    end
  end

  defp add_health_check_plug(zipper) do
    case Igniter.Code.Function.move_to_function_call_in_current_scope(
           zipper,
           :plug,
           [1, 2],
           &request_id_plug?/1
         ) do
      {:ok, request_id_zipper} ->
        Igniter.Code.Common.add_code(
          request_id_zipper,
          "plug KamalPlug.HealthCheck",
          placement: :before
        )

      :error ->
        Igniter.Code.Common.add_code(
          zipper,
          "plug KamalPlug.HealthCheck",
          placement: :before
        )
    end
  end

  defp health_check_plug?(zipper) do
    Igniter.Code.Function.argument_equals?(zipper, 0, KamalPlug.HealthCheck)
  end

  defp request_id_plug?(zipper) do
    Igniter.Code.Function.argument_equals?(zipper, 0, Plug.RequestId)
  end
end
