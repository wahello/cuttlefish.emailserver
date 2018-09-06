describe Mutations::CreateEmails do
  let(:context) { { current_admin: admin }}
  let(:variables) { {} }
  let(:result) {
    CuttlefishSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  }

  let(:team_one) { FactoryBot.create(:team) }
  let(:team_two) { FactoryBot.create(:team) }

  let(:admin) { FactoryBot.create(:admin, team: team_one) }
  let(:app1) { FactoryBot.create(:app, team: team_one) }
  let(:app2) { FactoryBot.create(:app, team: team_two) }

  let(:query_string) { 'mutation($id:ID!) { createEmails(appId: $id, from: "foo@foo.com", to: "bar@foo.com", subject: "An email", textPart: "Text!") { emails { id } } }' }
  let(:variables) { { id: app1.id } }

  it "should return a created email" do
    expect(result['data']['createEmails']['emails'].length).to eq 1
  end

  context "with no current user" do
    let(:context) { {} }

    it "should return nil and error" do
      expect(result['data']['createEmails']).to be_nil
      expect(result['errors'].length).to eq 1
      # TODO: Would be better to have a clearer error message for this situation
      expect(result['errors'][0]['message']).to eq "Not authorized to access Mutation.createEmails"
    end
  end

  context "with accessing an app belonging to a different team" do
    let(:variables) { { id: app2.id } }

    it "should return nil and an error" do
      expect(result['data']['createEmails']).to be_nil
      expect(result['errors'].length).to eq 1
      # TODO: Would be better to have a clearer (and more specific) error message for this situation
      expect(result['errors'][0]['message']).to eq "Not authorized to access Mutation.createEmails"
    end
  end

  context "non-existent app" do
    let(:variables) { { id: (app2.id + 1) } }

    it "should return nil and error" do
      expect(result['data']['createEmails']).to be_nil
      expect(result['errors'].length).to eq 1
      # This gives the same error message as line 44 so that one can't
      # tell the difference between a non-existent app and one that you don't have
      # access to but
      # TODO: Improve this error message
      expect(result['errors'][0]['message']).to eq "Not authorized to access Mutation.createEmails"
    end
  end

end