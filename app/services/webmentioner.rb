class Webmentioner
  include Backgroundable

  def initialize(source, target, opts = {})
    @source = source
    @target = target
    @opts = opts
  end

  def send!
    # If we can find a webmention endpoint, send a webmention; otherwise,
    # fallback to legacy /ping implementation.
    #
    Rails.logger.info "Sending webmention/ping for #{@source} (target: #{@target})"
    if endpoint = client.supports_webmention?(@target)
      Rails.logger.info "Sending webmention to #{endpoint}"
      client.send_mention(endpoint, @source, @target)
    else
      ping_url = URI.join(@target, '/ping')
      Rails.logger.info "Falling back to legacy ping on #{ping_url}"
      HTTParty.post(ping_url, body: { url: @source })
    end
  end

private

  def client
    Webmention::Client
  end
end
