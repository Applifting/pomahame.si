module Recaptchable
  def resolve_recaptcha(action, model, threshold = nil)
    score_threshold = threshold&.to_f

    if score_threshold.present?
      verify_recaptcha(action: action, minimum_score: score_threshold)
      recaptcha_response = recaptcha_reply
      recaptcha_result   = recaptcha_response['success'] == true

      if !recaptcha_result
        model.errors[:recaptcha] << 'si myslí, že jste robot. Zkusíte to znovu?'
        Rails.logger.warn "Recaptcha failed: #{recaptcha_response}"
        Raven.capture_exception AuthorisationError.new(:recaptcha, model)
        puts "RECAPTCHA RESULT: #{recaptcha_result}" if Rails.env.development?
      end

      recaptcha_result
    else
      true
    end
  end
end