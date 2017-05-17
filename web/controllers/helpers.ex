defmodule Karma.Controllers.Helpers do

  alias Karma.RedisCli

  def get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "User not in Redis"}
      {:ok, email} -> {:ok, email}
    end
  end

  def get_base_url() do
    dev_env? = Mix.env == :dev
    case dev_env? do
      true -> System.get_env("DEV_URL")
      false -> System.get_env("PROD_URL")
    end
  end

  def gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  defp sch_d() do
    "SCH D"
  end

  defp paye() do
    "PAYE"
  end

  defp conditional() do
    "CONDITIONAL"
  end

  def determine_contract_type(department, job_title) do
    case department do
      "Accounts" ->
        contract =
          case job_title == "Financial Controller" || job_title == "Production Accountant" do
            true -> sch_d()
            false -> paye()
          end
      "Action Vehicles" -> paye()
      "Assistant Director" ->
        contract =
          case job_title == "1st Assistant Director" do
            true -> sch_d()
            false -> paye()
          end
      "Aerial" -> sch_d()
      "Animals" ->
        contract =
          case job_title == "Animal Wrangler" || job_title == "Horse Master" do
            true -> sch_d()
            false -> paye()
          end
      "Armoury" ->
        contract =
          case job_title == "Archery Instructor"
          || job_title == "Armourer"
          || job_title == "Firearms Supervisor"
          || job_title == "HOD Armoury"
          || job_title == "Mechanical Engineer"
          || job_title == "Modeller"
          || job_title == "Standby Armourer" do
            true -> sch_d()
            false ->
              contract =
                case job_title == "Armoury Model Maker" || job_title == "Senior Model Maker" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Art" ->
        contract =
          case job_title == "Art Director"
          || job_title == "Production Designer"
          || job_title == "Senior Art Director"
          || job_title == "Set Designer"
          || job_title == "Standby Art Director"
          || job_title == "Storyboard Artist"
          || job_title == "Supervising Art Director" do
            true -> sch_d()
            false ->
              contract =
                case job_title == "Graphic Artist"
                || job_title == "Graphic Designer"
                || job_title == "Model Maker"
                || job_title == "Researcher/Consultancy"
                || job_title == "Scenic Painter" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Camera" ->
        contract =
          case job_title == "Director of Photography"
          || job_title == "DIT"
          || job_title == "Steadicam Operator"
          || job_title == "Stills Photographer" do
            true -> sch_d()
            false ->
              contract =
                case job_title == "Camera Operator" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Cast" ->
        contract =
          case job_title == "Actor Double"
          || job_title == "Cast Assistant"
          || job_title == "Cast Chef"
          || job_title == "Casting Assistant"
          || job_title == "Casting Associate"
          || job_title == "Stand In" do
            true -> paye()
            false ->
              contract =
                case job_title == "Unit Driver" do
                  true -> conditional()
                  false -> sch_d()
                end
          end
      "Construction" ->
        contract =
          case job_title == "Buyer"
          || job_title == "Construction Manager"
          || job_title == "Cast Chef"
          || job_title == "Modeller"
          || job_title == "Sculptor" do
            true -> sch_d()
            false ->
              contract =
                case job_title == "Scenic Painter" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Continuity" ->
        contract = case job_title == "Script Supervisor" do
          true -> sch_d()
          false -> paye()
        end
      "Costume" ->
        contract =
          case job_title == "Buyer"
          || job_title == "Costume Consultant"
          || job_title == "Costume Designer"
          || job_title == "Costume Prop Modeller"
          || job_title == "Modeller"
          || job_title == "Researcher"
          || job_title == "Sculptor"
          || job_title == "Jewellery Modeller" do
            true -> sch_d()
            false ->
              contract =
                case job_title == "Assistant Costume Designer"
                || job_title == "Costume Illustrator"
                || job_title == "Costume Supervisor"
                || job_title == "Head Milliner"
                || job_title == "Principal Seamstress"
                || job_title == "Seamstress" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "DIT" ->
        contract =
          case job_title == "Array DIT" || job_title == "DIT" do
            true -> conditional()
            false -> paye()
          end
      "Drapes" ->
        contract =
          case job_title == "Drapes Master" do
            true -> conditional()
            false -> paye()
          end
      "Editorial" ->
        contract =
          case job_title == "Assembly Editor"
          || job_title == "Associate Editor"
          || job_title == "Editor"
          || job_title == "VFX Editor" do
             true -> sch_d()
             false -> paye()
          end
      "Electrical" ->
        contract =
          case job_title == "Gaffer"
          || job_title == "HOD Electrical Rigger"
          || job_title == "HOD Rigger"
          || job_title == "Rigging Gaffer"
          || job_title == "Underwater Gaffer" do
            true -> sch_d()
            false ->
              contract =
                case job_title == "Balloon Technician" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Greens" -> paye()
      "Grip" ->
        contract =
          case job_title == "Assistant Grip"
          || job_title == "Grip Rigger"
          || job_title == "Grip Trainee" do
            true -> paye()
            false ->
              case job_title == "Best Boy Grip"
              || job_title == "Dolly Grip"
              || job_title == "Grip"
              || job_title == "Key Grip" do
                true -> conditional()
                false -> sch_d()
              end
          end
      "Hair and Makeup" ->
        contract =
          case job_title == "Crowd Hair/Makeup Supervisor"
          || job_title == "Crowd Makeup Artist"
          || job_title == "Hair & Makeup Artist"
          || job_title == "Makeup Artist"
          || job_title == "Makeup Designer"
          || job_title == "Key Hair And Make Up Artist"
          || job_title == "Hair & Makeup Designer"
          || job_title == "Hair Designer" do
            true -> sch_d()
            false -> paye()
          end
      "IT" -> paye()
      "Locations" ->
        case job_title == "Location Manager"
        || job_title == "Supervising Location Manager" do
          true -> sch_d()
          false -> paye()
        end
      "Medical" -> sch_d()
      "Military" -> sch_d()
      "Photography" -> conditional()
      "Post Production" ->
        case job_title == "Coordinator" do
          true -> paye()
          false -> sch_d()
        end
      "Production" ->
        case job_title == "Co-Producer"
        || job_title == "Executive Producer"
        || job_title == "Line Producer"
        || job_title == "Producer"
        || job_title == "Production Manager"
        || job_title == "Production Supervisor"
        || job_title == "Script Supervisor"
        || job_title == "Unit Production Manager" do
          true -> sch_d()
          false -> paye() 
        end
    end
  end

end
