defmodule Karma.StartpackControllerTest do
  use Karma.ConnCase

  alias Karma.Startpack
  import Mock
  @valid_attrs %{
    passport_expiry_date: %{day: 17, month: 4, year: 2010},
    country_of_legal_nationality: "some content",
    mobile_tel: "some content",
    vehicle_colour: "some content",
    emergency_contact_name: "some content",
    emergency_contact_tel: "some content",
    bank_account_number: "some content",
    bank_sort_code: "some content",
    loan_out_company_address: "some content",
    agent_bank_name: "some content",
    gender: "some content",
    student_loan_not_repayed?: true,
    equipment_rental_value: 42,
    country_of_permanent_residence: "some content",
    primary_address_postcode: "some content",
    bank_name: "some content",
    bank_account_users_full_name: "some content",
    box_rental_url: "some content",
    agent_name: "some content",
    box_rental_value: 42,
    vat_number: "some content",
    vehicle_registration: "some content",
    agent_bank_account_iban: "some content",
    loan_out_company_cert_url: "some content",
    middle_names: "some content",
    agent_bank_account_swift_code: "some content",
    for_paye_only: "some content",
    agent_email_address: "some content",
    schedule_d_letter_url: "some content",
    p45_url: "some content",
    agent_bank_sort_code: "some content",
    vehicle_make: "some content",
    bank_address: "some content",
    national_insurance_number: "some content",
    passport_issuing_country: "some content",
    agent_bank_address: "some content",
    equipment_rental_url: "some content",
    agent_deal?: true,
    student_loan_repay_direct?: true,
    bank_swift_code: "some content",
    vehicle_model: "some content",
    primary_address_country: "some content",
    passport_full_name: "some content",
    agent_tel: "some content",
    vehicle_insurance_url: "some content",
    student_loan_finished_before_6_april?: true,
    agent_company: "some content",
    primary_address_2: "some content",
    loan_out_company_registration_number: "some content",
    loan_out_company_address: "some content",
    loan_out_company_cert_url: "some content",
    bank_name: "some content",
    bank_address: "some content",
    bank_account_users_full_name: "some content",
    bank_account_number: "some content",
    bank_sort_code: "some content",
    bank_iban: "some content",
    bank_swift_code: "some content"
    }
  @invalid_attrs %{user_id: nil}


  setup do
    user = insert_user()
    project = insert_project(user)
    offer = insert_offer(project)
    startpack = insert_startpack(%{user_id: user.id})
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user, project: project, startpack: startpack, offer: offer}
  end

  test "edit startpack view on index", %{conn: conn} do
    conn = get conn, startpack_path(conn, :index)
    assert html_response(conn, 200) =~ "Edit startpack"
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    startpack = Repo.insert! %Startpack{user_id: user.id}
    conn = get conn, startpack_path(conn, :edit, startpack)
    assert html_response(conn, 200) =~ "Edit startpack"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, user: user, startpack: startpack} do
    conn = post conn, startpack_path(conn, :update, startpack), startpack: @valid_attrs
    assert redirected_to(conn) == startpack_path(conn, :index)
    assert Repo.get_by(Startpack, user_id: user.id)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, startpack: startpack} do
    conn = post conn, startpack_path(conn, :update, startpack), startpack: @invalid_attrs
    assert redirected_to(conn, 302) =~ "/startpack"
  end

  test "deletes chosen resource", %{conn: conn} do
    startpack = Repo.insert! %Startpack{}
    conn = delete conn, startpack_path(conn, :delete, startpack)
    assert redirected_to(conn) == startpack_path(conn, :index)
    refute Repo.get(Startpack, startpack.id)
  end

  test "offer id that doesn't exist :index", %{conn: conn} do
    conn = get conn, "/startpack?offer_id=1000"
    assert html_response(conn, 200) =~ "Edit startpack"
  end

  test "offer id that exists :index", %{conn: conn, offer: offer} do
    conn = get conn, "/startpack?offer_id=#{offer.id}"
    assert html_response(conn, 200) =~ "Edit startpack"
  end

  test "updates startpack and file is uploaded", %{conn: conn, user: user, startpack: startpack} do
    image_upload = %Plug.Upload{path: "test/fixtures/foxy.png", filename: "foxy.png"}
    valid = Map.put(@valid_attrs, "passport_image",  image_upload)

    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      conn = put conn, startpack_path(conn, :update, startpack), startpack: valid
      assert redirected_to(conn) == startpack_path(conn, :index)
      startpack = Repo.get_by(Startpack, user_id: user.id)
      assert startpack.passport_url
    end
  end

  test "update startpack leaves image url in if no file is added", %{conn: _conn} do
    user = insert_user(%{email: "new@test.com"})
    conn = login_user(build_conn(), user)
    startpack = Repo.insert! %Startpack{user_id: user.id, passport_url: "www.passport.com"}
    no_passport_image = Map.delete(@valid_attrs, "passport_url")
    conn = put conn, startpack_path(conn, :update, startpack), startpack: no_passport_image
    assert redirected_to(conn) == startpack_path(conn, :index)
    startpack = Repo.get_by(Startpack, user_id: user.id)
    assert startpack.passport_url == "www.passport.com"
  end

  test "updates startpack with many file uploads", %{conn: conn, user: user, startpack: startpack} do
    image_upload = %Plug.Upload{path: "test/fixtures/foxy.png", filename: "foxy.png"}

    # possible solution for multiple fields
    images = %{
     "passport_image"  => image_upload,
     "vehicle_insurance_image"  => image_upload,
     "box_rental_image"  => image_upload,
     "equipment_rental_image"  => image_upload,
     "p45_image"  => image_upload,
     "schedule_d_letter_image"  => image_upload,
     "loan_out_company_cert_image"  => image_upload
   }

    valid = Map.merge(@valid_attrs, images)

    with_mock ExAws, [request!: fn(_) ->
      Process.sleep(500)
      %{status_code: 200}
    end] do
      conn = put conn, startpack_path(conn, :update, startpack), startpack: valid
      assert redirected_to(conn) == startpack_path(conn, :index)
      startpack = Repo.get_by(Startpack, user_id: user.id)
      assert startpack.passport_url
    end
  end


  test "updates chosen resource even if file upload errors", %{conn: conn, user: user, startpack: startpack} do
    image_upload = %Plug.Upload{path: "test/fixtures/foxy.png", filename: "foxy.png"}
    valid = Map.put(@valid_attrs, "passport_image",  image_upload)

    with_mock ExAws, [request!: fn(_) -> %{status_code: 500} end] do
      conn = put conn, startpack_path(conn, :update, startpack), startpack: valid
      assert redirected_to(conn) == startpack_path(conn, :index)
      startpack = Repo.get_by(Startpack, user_id: user.id)
      assert startpack.gender == valid.gender
      refute startpack.passport_url
    end
  end
end