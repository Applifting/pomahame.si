# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    text { FFaker::HipsterIpsum.sentence }
    read_at { nil }
    outgoing
    pending

    trait :incoming do
      direction { :incoming }
    end

    trait :outgoing do
      direction { :outgoing }
    end

    trait :pending do
      state { :pending }
    end

    trait :sent do
      state { :sent }
    end

    trait :received do
      state { :received }
    end

    trait :other do
      message_type { :other }
    end

    trait :request_offer do
      message_type { :request_offer }
    end
  end
end
