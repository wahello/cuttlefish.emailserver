# frozen_string_literal: true

module EmailServices
  class CreateAndSend < ApplicationService
    def initialize(to:, data:, app_id:, ignore_deny_list:)
      super()
      @to = to
      @data = data
      @app_id = app_id
      @ignore_deny_list = ignore_deny_list
    end

    # Note that this service depends on having access to the same filesystem as
    # the worker processes have access to. Currently, that's fine because we're
    # running everything on a single machine but that assumption might not be
    # true in the future
    def call
      email = Email.create!(
        to: to,
        data: data,
        app_id: app_id,
        ignore_deny_list: ignore_deny_list
      )

      SendEmailWorker.new.perform(email.id)

      success!
      email
    end

    private

    attr_reader :to, :data, :app_id, :ignore_deny_list
  end
end