require 'rails_helper'

describe PostFetcher do
  let(:post) { create(:post, slug: 'foo123', domain: 'somehost') }
  let(:url)  { "http://#{post.domain}/#{post.slug}.json" }
  let(:data) do
    {
      guid:             post.guid,
      url:              url,
      published_at:     post.published_at,
      edited_at:        post.edited_at,
      referenced_guid:  post.referenced_guid,
      body:             post.body,
      body_html:        post.body_html,
      domain:           post.domain,
      slug:             post.slug,
      tags:             post.tags
    }.with_indifferent_access
  end
  let(:opts) { Hash.new }

  subject { PostFetcher.new(url, opts) }

  describe '#perform' do
    it "expands the given URL"
    it "fetches the remote JSON"
    it "upserts a Post instance"
    it "adds the post to local followers' timelines"

    context "when a recipient is specified" do
      it "adds the post to the recipient's timeline"
    end
  end

  describe '#expand_url' do
    it "adds a protocol if none is given" do
      expect(subject.expand_url("somehost/foo123.json"))
        .to eq("http://somehost/foo123.json")
    end

    it "doesn't change the exisiting protocol" do
      expect(subject.expand_url("https://somehost/foo123.json"))
        .to eq("https://somehost/foo123.json")
    end
  end

  describe '#fetch_json' do
    before do
      stub_request(:get, url)
        .to_return(status: 200, body: data.to_json, headers: { content_type: 'application/json' })
    end

    it "executes a HTTP request against the specified URL" do
      subject.fetch_json
    end
  end

  describe '#json_sane?' do
    xit "returns true if JSON data matches URL" do
      expect(subject.json_sane?).to eq(true)
    end

    xit "raises an error if GUID is different from the one contained in URL" do
      expect { subject.json_sane?(data.merge(guid: "h4x"), url) }
        .to raise_error
    end

    xit "raises an error if slug is different from the one contained in URL" do
      expect { subject.json_sane?(data.merge(slug: "h4x"), url) }
        .to raise_error
    end

    xit "raises an error if domain is different from the one contained in URL" do
      expect { subject.json_sane?(data.merge(domain: "h4x"), url) }
        .to raise_error
    end
  end
end
