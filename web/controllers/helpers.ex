defmodule Karma.Controllers.Helpers do

  alias Karma.RedisCli

  def user_startpack(user) do
    Ecto.assoc(user, :startpacks)
  end

  def user_offers(user) do
    Ecto.assoc(user, :offers)
  end

  def user_projects(user) do
    Ecto.assoc(user, :projects)
  end

  def project_signees(project) do
    Ecto.assoc(project, :signees)
  end

  def get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "User not in Redis"}
      {:ok, email} -> {:ok, email}
    end
  end

  def get_category(file_type) do
    case Enum.member?([
      "DIRECT HIRE",
      "PAYE",
      "SCHEDULE-D",
      "LOAN OUT",
      "CONSTRUCTION DIRECT HIRE",
      "CONSTRUCTION PAYE",
      "CONSTRUCTION SCHEDULE-D",
      "CONSTRUCTION LOAN OUT",
      "BOX RENTAL FORM",
      "EQUIPMENT RENTAL FORM",
      "VEHICLE ALLOWANCE FORM"
      ], file_type) do
        true -> "Deal"
        false ->
          case Enum.member?([
            "NDA",
            "INFO DOCUMENT RECEIPT DECLARATION",
            "COMPLIANCE TRAINING"
            ], file_type) do
              true -> "Form"
              false -> "Info"
            end
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

  def calc_day_fee_inc_holidays(fee_per_day_inc_holiday, day_fee_multiplier) do
    fee_per_day_inc_holiday * day_fee_multiplier
  end

  def calc_day_fee_exc_holidays(fee_per_day_exc_holiday, day_fee_multiplier) do
    fee_per_day_exc_holiday * day_fee_multiplier
  end

  def calc_fee_per_day_exc_holiday(fee_per_day_inc_holiday, project_holiday_rate) do
    divisible_rate = 1 + project_holiday_rate
    round(fee_per_day_inc_holiday / divisible_rate)
  end

  def calc_holiday_pay_per_day(fee_per_day_inc_holiday, fee_per_day_exc_holiday) do
    round(fee_per_day_inc_holiday - fee_per_day_exc_holiday)
  end

  def calc_fee_per_week_inc_holiday(fee_per_day_inc_holiday, working_week) do
    round(fee_per_day_inc_holiday * working_week)
  end

  def calc_fee_per_week_exc_holiday(fee_per_week_inc_holiday, project_holiday_rate) do
    round(fee_per_week_inc_holiday / (1 + project_holiday_rate))
  end

  def calc_holiday_pay_per_week(fee_per_week_inc_holiday, fee_per_week_exc_holiday) do
    round(fee_per_week_inc_holiday - fee_per_week_exc_holiday)
  end

  defp sch_d() do
    "SCHEDULE-D"
  end

  defp paye() do
    "PAYE"
  end

  defp conditional() do
    # "CONDITIONAL"
    "PAYE"
  end

  def determine_contract_type(department, job_title) do
    case department do
      "" -> ""
      "Accounts" ->
          case job_title == "Financial Controller" || job_title == "Production Accountant" do
            true -> sch_d()
            false -> paye()
          end
      "Action Vehicles" -> paye()
      "Assistant Director" ->
          case job_title == "1st Assistant Director" do
            true -> sch_d()
            false -> paye()
          end
      "Aerial" -> sch_d()
      "Animals" ->
          case job_title == "Animal Wrangler" || job_title == "Horse Master" do
            true -> sch_d()
            false -> paye()
          end
      "Armoury" ->
          case Enum.member?(["Archery Instructor",
          "Armourer",
          "Firearms Supervisor",
          "HOD Armoury",
          "Mechanical Engineer",
          "Modeller",
          "Standby Armourer"], job_title) do
            true -> sch_d()
            false ->
                case Enum.member?(["Armoury Model Maker",
                "Senior Model Maker"], job_title) do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Art" ->
          case Enum.member?(["Art Director",
          "Production Designer",
          "Senior Art Director",
          "Set Designer",
          "Standby Art Director",
          "Storyboard Artist",
          "Supervising Art Director"], job_title) do
            true -> sch_d()
            false ->
                case Enum.member?(["Graphic Artist",
                "Graphic Designer",
                "Model Maker",
                "Researcher/Consultancy",
                "Scenic Painter"], job_title) do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Camera" ->
          case Enum.member?(["Director Of Photography",
          "DIT",
          "Steadicam Operator",
          "Stills Photographer"], job_title) do
            true -> sch_d()
            false ->
                case job_title == "Camera Operator" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Cast" ->
          case Enum.member?(["Actor Double",
          "Cast Assistant",
          "Cast Chef",
          "Casting Assistant",
          "Casting Associate",
          "Stand In"], job_title) do
            true -> paye()
            false ->
                case job_title == "Unit Driver" do
                  true -> conditional()
                  false -> sch_d()
                end
          end
      "Construction" ->
          case Enum.member?(["Buyer",
          "Construction Manager",
          "Cast Chef",
          "Modeller",
          "Sculptor"], job_title) do
            true -> sch_d()
            false ->
                case job_title == "Scenic Painter" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Continuity" ->
         case job_title == "Script Supervisor" do
          true -> sch_d()
          false -> paye()
        end
      "Costume" ->
          case Enum.member?(["Buyer",
          "Costume Consultant",
          "Costume Designer",
          "Costume Prop Modeller",
          "Modeller",
          "Researcher",
          "Sculptor",
          "Jewellery Modeller"], job_title) do
            true -> sch_d()
            false ->
                case Enum.member?(["Assistant Costume Designer",
                "Costume Illustrator",
                "Costume Supervisor",
                "Head Milliner",
                "Principal Seamstress",
                "Seamstress"], job_title) do
                  true -> conditional()
                  false -> paye()
                end
          end
      "DIT" ->
          case job_title == "Array DIT" || job_title == "DIT" do
            true -> conditional()
            false -> paye()
          end
      "Drapes" ->
          case job_title == "Drapes Master" do
            true -> conditional()
            false -> paye()
          end
      "Editorial" ->
          case Enum.member?(["Assembly Editor",
          "Associate Editor",
          "Editor",
          "VFX Editor"], job_title) do
             true -> sch_d()
             false -> paye()
          end
      "Electrical" ->
          case Enum.member?(["Gaffer",
          "HOD Electrical Rigger",
          "HOD Rigger",
          "Rigging Gaffer",
          "Underwater Gaffer",
          "VFX Editor"], job_title) do
            true -> sch_d()
            false ->
                case job_title == "Balloon Technician" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Greens" -> paye()
      "Grip" ->
          case Enum.member?(["Assistant Grip",
          "Grip Rigger",
          "Grip Trainee"], job_title) do
            true -> paye()
            false ->
              case Enum.member?(["Best Boy Grip",
              "Dolly Grip",
              "Grip",
              "Key Grip"], job_title) do
                true -> conditional()
                false -> sch_d()
              end
          end
      "Hair And Makeup" ->
          case Enum.member?(["Crowd Hair/Makeup Supervisor",
          "Crowd Makeup Artist",
          "Hair & Makeup Artist",
          "Makeup Artist",
          "Makeup Designer",
          "Key Hair And Make Up Artist",
          "Hair & Makeup Designer",
          "Hair Designer"], job_title) do
            true -> sch_d()
            false -> paye()
          end
      "IT" -> paye()
      "Locations" ->
          case Enum.member?(["Location Manager",
          "Supervising Location Manager"], job_title) do
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
          case Enum.member?(["Co-Producer",
          "Executive Producer",
          "Line Producer",
          "Producer",
          "Production Manager",
          "Production Supervisor",
          "Script Supervisor",
          "Unit Production Manager"], job_title) do
            true -> sch_d()
            false -> paye()
          end
      "Props" ->
          case Enum.member?(["3D Modeller",
          "Action Prop Buyer",
          "HOD Prop Modeller",
          "Modeller",
          "On Set Props Master",
          "Property Master",
          "Props Buyer",
          "Props Buyer/Researcher",
          "Sculptor",
          "Senior Modeller"], job_title) do
            true -> sch_d()
            false ->
                case Enum.member?(["Chargehand Dressing Prop",
                "Chargehand Prop",
                "Drapesmaster",
                "Model Maker",
                "Prophand",
                "Propman",
                "Senior Model Maker",
                "Senior Prop Hand",
                "Supervising Prop Hand"], job_title) do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Publicity" -> sch_d()
      "Rigging" ->
          case job_title == "HOD Rigger" do
            true -> sch_d()
            false -> paye()
          end
      "Security" -> paye()
      "Set Dec" ->
          case Enum.member?(["Art Director",
          "Graphic Designer",
          "Location Buyer",
          "Production Buyer",
          "Set Decorator"], job_title) do
             true -> sch_d()
             false ->
                 case job_title == "Scenic Textile Artist" do
                   true -> conditional()
                   false -> paye()
                 end
          end
      "SFX" ->
          case Enum.member?(["Floor Director",
          "Lead Snr SFX Technician",
          "Prep Lead Senior Tech",
          "Senior SFX Floor Technician",
          "Senior SFX Technician",
          "SFX Buyer",
          "SFX Floor Supervisor",
          "SFX Senior Technician",
          "SFX Supervisor",
          "Workshop Supervisor"], job_title) do
             true -> sch_d()
             false -> paye()
          end
      "Sound" ->
          case Enum.member?(["Production Sound Mixer",
          "Sound Maintenance",
          "Sound Mixer"], job_title) do
             true -> sch_d()
             false -> paye()
          end
      "Standby" -> paye()
      "Studio Unit" -> paye()
      "Stunts" ->
          case Enum.member?(["Rigger",
          "Stunt Department Coordinator",
          "Stunt Department Supervisor"], job_title) do
             true -> paye()
             false ->
                 case job_title == "Wire Rigger" do
                   true -> conditional()
                   false -> sch_d()
                 end
          end
      "Supporting Artist" -> sch_d()
      "Transport" ->
          case Enum.member?(["Transport Captain",
          "Transport Manager"], job_title) do
            true -> sch_d()
            false ->
                case job_title == "Unit Driver" do
                  true -> conditional()
                  false -> paye()
                end
          end
      "Underwater" -> sch_d()
      "VFX" ->
          case job_title == "VFX Producer" do
            true -> sch_d()
            false -> paye()
          end
      "Video" -> paye()
      "Voice" -> sch_d()
    end
  end
end
