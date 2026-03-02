Mix.install([{:igniter, "~> 0.6"}])

igniter = Igniter.new()
{igniter, endpoint} = Igniter.Libs.Phoenix.select_endpoint(igniter)

if endpoint do
  igniter =
    Igniter.Project.Module.find_and_update_module!(igniter, endpoint, fn zipper ->
      already_installed? =
        case Igniter.Code.Function.move_to_function_call_in_current_scope(
               zipper,
               :plug,
               [1, 2],
               &Igniter.Code.Function.argument_equals?(&1, 0, KamalPlug.HealthCheck)
             ) do
          {:ok, _} -> true
          :error -> false
        end

      if already_installed? do
        {:ok, zipper}
      else
        case Igniter.Code.Function.move_to_function_call_in_current_scope(
               zipper,
               :plug,
               [1, 2],
               &Igniter.Code.Function.argument_equals?(&1, 0, Plug.RequestId)
             ) do
          {:ok, request_id_zipper} ->
            {:ok,
             Igniter.Code.Common.add_code(
               request_id_zipper,
               "plug KamalPlug.HealthCheck",
               placement: :before
             )}

          :error ->
            {:ok,
             Igniter.Code.Common.add_code(
               zipper,
               "plug KamalPlug.HealthCheck",
               placement: :before
             )}
        end
      end
    end)

  Igniter.do_or_dry_run(igniter)
else
  igniter
  |> Igniter.add_warning("No Phoenix endpoint found")
  |> Igniter.do_or_dry_run()
end
