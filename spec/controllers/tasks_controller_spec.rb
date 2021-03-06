# frozen_string_literal: true

RSpec.describe TasksController, type: :request do
  subject(:controller) { described_class.new }

  let!(:user) { create(:user) }
  let(:authorization_header) { JWTSessions::Session.new(payload: { user_id: user.id }).login[:access] }
  let(:headers) { { 'Authorization' => authorization_header } }
  let!(:to_do_list) { create(:to_do_list_with_tasks, user: user) }

  it 'has correct parent' do
    expect(controller).to be_a_kind_of(ApplicationController)
  end

  describe '#index' do
    let(:endpoint_call) do
      get to_do_list_tasks_path(to_do_list), headers: headers, as: :json
    end

    context 'when params are valid' do
      it 'returns correct response' do
        endpoint_call

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to match_json_schema('tasks/list')
      end
    end

    context 'when params are invalid' do
      before do
        endpoint_call
      end

      let(:to_do_list) { 'invalid' }

      it_behaves_like 'validation errors'
    end
  end

  describe '#create' do
    let(:endpoint_call) do
      post to_do_list_tasks_path(to_do_list), params: params, headers: headers, as: :json
    end

    context 'when params are valid' do
      let(:params) { { title: Faker::Tea.variety } }

      it 'creates task' do
        expect { endpoint_call }.to change(Task, :count).by(1)
      end

      it 'returns correct response' do
        endpoint_call

        expect(response).to be_created
        expect(JSON.parse(response.body)).to match_json_schema('tasks/single')
      end
    end

    context 'when params are invalid' do
      before do
        endpoint_call
      end

      let(:params) { { title: Faker::Lorem.characters(number: Task::TITLE_MAX_LENGTH + 1) } }

      it_behaves_like 'validation errors'
    end
  end

  describe '#show' do
    let(:endpoint_call) do
      get to_do_list_task_path(to_do_list, task), headers: headers, as: :json
    end

    context 'when params are valid' do
      let(:task) { to_do_list.tasks.sample }

      it 'returns correct response' do
        endpoint_call

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to match_json_schema('tasks/single')
      end
    end

    context 'when params are invalid' do
      before do
        endpoint_call
      end

      let(:task) { 'invalid' }

      it_behaves_like 'validation errors'
    end
  end

  describe '#update' do
    let(:endpoint_call) do
      put to_do_list_task_path(to_do_list, task), params: params, headers: headers, as: :json
    end
    let(:task) { to_do_list.tasks.sample }

    context 'when params are valid' do
      let(:params) { { title: Faker::Tea.variety } }

      it 'returns correct response' do
        endpoint_call

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to match_json_schema('tasks/single')
      end
    end

    context 'when params are invalid' do
      before do
        endpoint_call
      end

      let(:params) { { title: Faker::Lorem.characters(number: Task::TITLE_MAX_LENGTH + 1) } }

      it_behaves_like 'validation errors'
    end
  end

  describe '#destroy' do
    let(:endpoint_call) do
      delete to_do_list_task_path(to_do_list, task), headers: headers, as: :json
    end

    context 'when params are valid' do
      let(:task) { to_do_list.tasks.sample }

      it 'destroys task' do
        expect { endpoint_call }.to change(Task, :count).by(-1)
      end

      it 'returns correct response' do
        endpoint_call

        expect(response).to be_no_content
        expect(response.body).to be_empty
      end
    end

    context 'when params are invalid' do
      before do
        endpoint_call
      end

      let(:task) { 'invalid' }

      it_behaves_like 'validation errors'
    end
  end

  describe '#change_position' do
    let(:endpoint_call) do
      patch change_position_to_do_list_task_path(to_do_list, task), params: params, headers: headers, as: :json
    end
    let(:task) { to_do_list.tasks.sample }

    context 'when params are valid' do
      let(:new_position) { to_do_list.tasks.pluck(:position).sample }
      let(:params) { { new_position: new_position } }

      it 'updates task\'s position' do
        endpoint_call

        expect(JSON.parse(response.body)['data']['attributes']['position']).to eq(new_position)
      end

      it 'returns correct response' do
        endpoint_call

        expect(response).to be_ok
        expect(JSON.parse(response.body)).to match_json_schema('tasks/single')
      end
    end

    context 'when params are invalid' do
      before do
        endpoint_call
      end

      let(:params) { { new_position: -1 } }

      it_behaves_like 'validation errors'
    end
  end
end
