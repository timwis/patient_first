defmodule PatientFirst.Repo do
  use Ecto.Repo,
    otp_app: :patient_first,
    adapter: Ecto.Adapters.Postgres
end
