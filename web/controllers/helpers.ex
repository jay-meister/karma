defmodule Engine.Controllers.Helpers do
  import Ecto.Query
  alias Engine.{Document, RedisCli}


  def user_startpack(user) do
    Ecto.assoc(user, :startpacks)
  end

  # def user_offers(user) do
  #   Ecto.assoc(user, :offers)
  # end

  def user_projects(user) do
    Ecto.assoc(user, :projects)
  end

  def project_documents(project) do
    Ecto.assoc(project, :documents)
  end

  def project_signees(project) do
    from s in Engine.Signee,
    where: s.project_id == ^project.id,
    order_by: s.approver_type,
    order_by: s.name
  end

  def project_custom_fields(project) do
    Ecto.assoc(project, :custom_fields)
  end

  def document_signees(document) do
    Ecto.assoc(document, :signees)
  end

  def get_forms_for_merging(offer) do
    Document
    |> Document.get_contract(offer)
    |> Document.get_conditional_form(offer, true, "START FORM")
    |> Document.get_conditional_form(offer, offer.box_rental_required?, "BOX INVENTORY")
    |> Document.get_conditional_form(offer, offer.equipment_rental_required?, "EQUIPMENT INVENTORY")
    |> Document.get_conditional_form(offer, offer.vehicle_allowance_per_week != 0, "VEHICLE ALLOWANCE")
  end

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

  def calc_day_fee_inc_holidays(fee_per_day_inc_holiday, day_fee_multiplier) do
    Float.round(((fee_per_day_inc_holiday * day_fee_multiplier) / 1), 2)
  end

  def calc_day_fee_exc_holidays(fee_per_day_exc_holiday, day_fee_multiplier) do
    Float.round(((fee_per_day_exc_holiday * day_fee_multiplier) / 1), 2)
  end

  def calc_fee_per_day_exc_holiday(fee_per_day_inc_holiday, project_holiday_rate) do
    divisible_rate = 1 + project_holiday_rate
    Float.round((fee_per_day_inc_holiday / divisible_rate), 2)
    # round(fee_per_day_inc_holiday / divisible_rate)
  end

  def calc_holiday_pay_per_day(fee_per_day_inc_holiday, fee_per_day_exc_holiday) do
    Float.round((fee_per_day_inc_holiday - fee_per_day_exc_holiday), 2)
  end

  def calc_fee_per_week_inc_holiday(fee_per_day_inc_holiday, working_week) do
    Float.round((fee_per_day_inc_holiday * working_week), 2)
  end

  def calc_fee_per_week_exc_holiday(fee_per_week_inc_holiday, project_holiday_rate) do
    Float.round((fee_per_week_inc_holiday / (1 + project_holiday_rate)), 2)
  end

  def calc_holiday_pay_per_week(fee_per_week_inc_holiday, fee_per_week_exc_holiday) do
    Float.round((fee_per_week_inc_holiday - fee_per_week_exc_holiday), 2)
  end

  def calc_holiday_pay_difference(fee_inc_holiday, fee_exc_holiday) do
    Float.round(fee_inc_holiday - fee_exc_holiday)
  end

  defp construction_sch_d(construction_direct_hire, daily_construction_direct_hire, daily_construction_sch_d) do
    case construction_direct_hire do
      true ->
        case daily_construction_direct_hire do
          true -> "DAILY CONSTRUCTION DIRECT HIRE"
          false -> "CONSTRUCTION DIRECT HIRE"
        end
      false ->
        case daily_construction_direct_hire do
          true -> "DAILY CONSTRUCTION DIRECT HIRE"
          false ->
            case daily_construction_sch_d do
              true -> "DAILY CONSTRUCTION SCHEDULE-D"
              false -> "CONSTRUCTION SCHEDULE-D"
            end

        end
    end
  end

  defp construction_paye(construction_direct_hire, daily_construction_direct_hire, daily_construction_paye) do
    case construction_direct_hire do
      true ->
        case daily_construction_direct_hire do
          true -> "DAILY CONSTRUCTION DIRECT HIRE"
          false -> "CONSTRUCTION DIRECT HIRE"
        end
      false ->
        case daily_construction_direct_hire do
          true -> "DAILY CONSTRUCTION DIRECT HIRE"
          false ->
            case daily_construction_paye do
              true -> "DAILY CONSTRUCTION PAYE"
              false -> "CONSTRUCTION PAYE"
            end
        end
    end
  end

  defp construction_conditional() do
    # "CONDITIONAL"
    "CONSTRUCTION PAYE"
  end

  defp transport_paye(transport_direct_hire, daily_transport_direct_hire, daily_transport_paye) do
    case transport_direct_hire do
      true ->
        case daily_transport_direct_hire do
          true -> "DAILY TRANSPORT DIRECT HIRE"
          false -> "TRANSPORT DIRECT HIRE"
        end
      false ->
        case daily_transport_direct_hire do
          true -> "DAILY TRANSPORT DIRECT HIRE"
          false ->
            case daily_transport_paye do
              true -> "DAILY TRANSPORT PAYE"
              false -> "TRANSPORT PAYE"
            end
        end
    end
  end

  defp transport_conditional() do
    # "CONDITIONAL"
    "TRANSPORT PAYE"
  end

  defp sch_d(direct_hire, daily_direct_hire, daily_sch_d) do
    case direct_hire do
      true ->
        case daily_direct_hire do
          true -> "DAILY DIRECT HIRE"
          false -> "DIRECT HIRE"
        end
      false ->
        case daily_direct_hire do
          true -> "DAILY DIRECT HIRE"
          false ->
            case daily_sch_d do
              true -> "DAILY SCHEDULE-D"
              false -> "SCHEDULE-D"
            end
        end
    end
  end

  defp paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title) do
    case direct_hire do
      true ->
        case daily_direct_hire do
          true -> "DAILY DIRECT HIRE"
          false -> "DIRECT HIRE"
        end
      false ->
        case daily_direct_hire do
          true -> "DAILY DIRECT HIRE"
          false ->
            provision_of_equipment(department, job_title, equipment)
            |> prepend_with_daily(daily_paye)
        end
    end
  end

  defp conditional(equipment) do
    case equipment do
      true -> "SCHEDULE-D"
      false -> "PAYE"
    end
  end

  defp prepend_with_daily(current, daily) do
    if daily, do: "DAILY " <> current, else: current
  end

  defp provision_of_equipment(department, job_title, equipment) do
    # all of these department & job title combinations should be made from PAYE
    # to SCHEDULE D if equipment allowance in offer
    replace_with_sched_d =
      %{"Armoury": ["Armoury Model Maker", "Senior Model Maker"],
      "Art":  ["Model Maker"],
      "Camera": ["Camera Operator"],
      "Costume": ["Assistant Costume Designer", "Costume Supervisor", "Head Milliner"],
      "DIT": ["Array DIT", "DIT"],
      "Drapes": ["Drapes Master"],
      "Electrical": ["Balloon Technician"],
      "Grip": ["Best Boy Grip", "Dolly Grip", "Grip", "Key Grip"],
      "Photography": ["Photographer"],
      "Props": ["Chargehand Dressing Prop", "Chargehand Prop", "Drapesmaster", "Prophand", "Propman", "Senior Prop Hand", "Supervising Prop Hand"],
      "Stunts": ["Wire Rigger"]
    }

    # if job title isn't in the list, set it to false so it will always return PAYE
    job_titles = Map.get(replace_with_sched_d, department) || false

    case equipment && job_titles && Enum.member?(job_titles, job_title) do
      true ->
        "SCHEDULE-D"
      false ->
        "PAYE"
    end
  end

  def determine_contract_type(department, job_title, project_documents, daily, equipment) do
    direct_hire = Enum.member?(project_documents, "DIRECT HIRE")
    daily_direct_hire = daily && Enum.member?(project_documents, "DAILY DIRECT HIRE")
    construction_direct_hire = Enum.member?(project_documents, "CONSTRUCTION DIRECT HIRE")
    daily_construction_direct_hire = daily && Enum.member?(project_documents, "DAILY CONSTRUCTION DIRECT HIRE")
    daily_construction_paye = daily && Enum.member?(project_documents, "DAILY CONSTRUCTION PAYE")
    daily_construction_sch_d = daily && Enum.member?(project_documents, "DAILY CONSTRUCTION SCHEDULE-D")
    transport_direct_hire = Enum.member?(project_documents, "TRANSPORT DIRECT HIRE")
    daily_transport_paye = daily && Enum.member?(project_documents, "DAILY TRANSPORT PAYE")
    daily_transport_sch_d = daily && Enum.member?(project_documents, "DAILY TRANSPORT SCHEDULE-D")
    daily_transport_direct_hire = daily && Enum.member?(project_documents, "DAILY TRANSPORT DIRECT HIRE")
    daily_paye = daily && Enum.member?(project_documents, "DAILY PAYE")
    daily_sch_d = daily && Enum.member?(project_documents, "DAILY SCHEDULE-D")
    case department do
      "" -> ""
      "Accounts" ->
          case job_title == "Financial Controller" || job_title == "Production Accountant" || job_title == "Accountant" do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Action Vehicles" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Assistant Director" ->
          case job_title == "1st Assistant Director" do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Aerial" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
      "Animals" ->
          case job_title == "Animal Wrangler" || job_title == "Horse Master" do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Armoury" ->
          case Enum.member?(["Archery Instructor",
          "Armourer",
          "Firearms Supervisor",
          "HOD Armoury",
          "Mechanical Engineer",
          "Modeller",
          "Standby Armourer"], job_title) do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false ->
                case Enum.member?(["Armoury Model Maker",
                "Senior Model Maker"], job_title) do
                  true -> conditional(equipment)
                  false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
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
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false ->
                case Enum.member?(["Graphic Artist",
                "Graphic Designer",
                "Model Maker",
                "Researcher/Consultancy",
                "Scenic Painter"], job_title) do
                  true -> conditional(equipment)
                  false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
                end
          end
      "Camera" ->
          case Enum.member?(["Director Of Photography",
          "DIT",
          "Steadicam Operator",
          "Stills Photographer"], job_title) do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false ->
                case Enum.member?(["Camera Operator", "Camera Operator - B Camera", "Camera Operator - A Camera"], job_title) do
                  true -> conditional(equipment)
                  false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
                end
          end
      "Cast" ->
          case Enum.member?(["Actor Double",
          "Cast Assistant",
          "Cast Chef",
          "Casting Assistant",
          "Casting Associate",
          "Stand In"], job_title) do
            true -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
            false ->
                case job_title == "Unit Driver" do
                  true -> conditional(equipment)
                  false -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
                end
          end
      "Construction" ->
          case Enum.member?(["Buyer",
          "Construction Manager",
          "Cast Chef",
          "Modeller",
          "Sculptor"], job_title) do
            true -> construction_sch_d(construction_direct_hire, daily_construction_direct_hire, daily_construction_sch_d)
            false ->
                case job_title == "Scenic Painter" do
                  true -> construction_conditional()
                  false -> construction_paye(construction_direct_hire, daily_construction_direct_hire, daily_construction_paye)
                end
          end
      "Continuity" ->
         case job_title == "Script Supervisor" do
          true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
          false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
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
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false ->
                case Enum.member?(["Assistant Costume Designer",
                "Costume Illustrator",
                "Costume Supervisor",
                "Head Milliner",
                "Principal Seamstress",
                "Seamstress"], job_title) do
                  true -> conditional(equipment)
                  false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
                end
          end
      "DIT" ->
          case job_title == "Array DIT" || job_title == "DIT" do
            true -> conditional(equipment)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Drapes" ->
          case job_title == "Drapes Master" do
            true -> conditional(equipment)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Editorial" ->
          case Enum.member?(["Assembly Editor",
          "Associate Editor",
          "Editor",
          "VFX Editor"], job_title) do
             true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
             false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Electrical" ->
          case Enum.member?(["Gaffer",
          "HOD Electrical Rigger",
          "HOD Rigger",
          "Rigging Gaffer",
          "Underwater Gaffer",
          "VFX Editor"], job_title) do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false ->
                case job_title == "Balloon Technician" do
                  true -> conditional(equipment)
                  false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
                end
          end
      "Greens" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Grip" ->
          case Enum.member?(["Assistant Grip",
          "Grip Rigger",
          "Grip Trainee"], job_title) do
            true -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
            false ->
              case Enum.member?(["Best Boy Grip",
              "Dolly Grip",
              "Grip",
              "Key Grip"], job_title) do
                true -> conditional(equipment)
                false -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
              end
          end
      "Hair And Makeup" ->
          case Enum.member?(["Crowd Hair/Makeup Supervisor",
          "Crowd Makeup Artist",
          "Hair and Makeup Artist",
          "Makeup Artist",
          "Makeup Designer",
          "Key Hair And Make Up Artist",
          "Hair and Makeup Designer",
          "Hair and Makeup Supervisor",
          "Hair Designer"], job_title) do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "IT" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Locations" ->
          case Enum.member?(["Location Manager",
          "Supervising Location Manager"], job_title) do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Medical" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
      "Military" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
      "Photography" -> conditional(equipment)
      "Post Production" ->
          case job_title == "Coordinator" do
            true -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
            false -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
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
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
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
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
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
                  true -> conditional(equipment)
                  false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
                end
          end
      "Publicity" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
      "Rigging" ->
          case job_title == "HOD Rigger" do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Security" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Set Dec" ->
          case Enum.member?(["Art Director",
          "Graphic Designer",
          "Location Buyer",
          "Production Buyer",
          "Set Decorator"], job_title) do
             true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
             false ->
                 case job_title == "Scenic Textile Artist" do
                   true -> conditional(equipment)
                   false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
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
             true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
             false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Sound" ->
          case Enum.member?(["Production Sound Mixer", "Sound Maintenance", "Sound Mixer", "Sound Recordist"], job_title) do
             true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
             false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Standby" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Studio Unit" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Stunts" ->
          case Enum.member?(["Rigger",
          "Stunt Department Coordinator",
          "Stunt Department Supervisor"], job_title) do
             true -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
             false ->
                 case job_title == "Wire Rigger" do
                   true -> conditional(equipment)
                   false -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
                 end
          end
      "Supporting Artist" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
      "Transport" ->
          case Enum.member?(["Transport Captain",
          "Transport Manager"], job_title) do
            true -> sch_d(direct_hire, daily_direct_hire, daily_transport_sch_d)
            false ->
                case job_title == "Unit Driver" do
                  true -> transport_conditional()
                  false ->
                    case job_title == "Transport Coordinator" do
                      true -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
                      false -> transport_paye(transport_direct_hire, daily_transport_direct_hire, daily_transport_paye)
                    end
                end
          end
      "Underwater" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
      "VFX" ->
          case job_title == "VFX Producer" do
            true -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
            false -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
          end
      "Video" -> paye(direct_hire, daily_direct_hire, daily_paye, equipment, department, job_title)
      "Voice" -> sch_d(direct_hire, daily_direct_hire, daily_sch_d)
    end
  end
end
