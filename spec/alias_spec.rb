require 'spec_helper'

describe 'Blog aliases configuration' do
  let(:app) do
    app = middleman_app('alias-app') do
      activate :blog do |blog|
        blog.permalink = ':year/:month/:day/:title.html'
        blog.aliases = [
          ':year-:month-:day-:title.html',
          ':year/:month-:day-:title'
        ]
      end
    end
    app
  end

  describe 'alias URL generation' do
    let(:article) { app.sitemap.find_resource_by_path('2024/03/14/pi-day.html') }
    let(:alias_resources) { app.sitemap.resources.select { |r| r.metadata&.dig(:locals, 'page_type') == 'alias' } }

    it 'generates the main article permalink correctly' do
      expect(article).to be_present
      expect(article.destination_path).to eq('2024/03/14/pi-day.html')
    end

    it 'generates alias resources for each pattern' do
      expect(alias_resources.length).to eq(2)
      
      alias_paths = alias_resources.map(&:destination_path).sort
      expect(alias_paths).to eq([
        '2024-03-14-pi-day.html',
        '2024/03-14-pi-day'
      ].sort)
    end

    it 'sets correct redirect target for aliases' do
      alias_resources.each do |alias_resource|
        expect(alias_resource.metadata[:locals]['redirect_to']).to eq('2024/03/14/pi-day.html')
        expect(alias_resource.metadata[:locals]['page_type']).to eq('alias')
      end
    end

    it 'does not create alias that matches the main permalink' do
      # No alias should have the same path as the main article
      main_path = article.destination_path
      alias_paths = alias_resources.map(&:destination_path)
      expect(alias_paths).not_to include(main_path)
    end
  end

  describe 'empty aliases configuration' do
    let(:app_no_aliases) do
      middleman_app('blog-sources-app') do
        activate :blog do |blog|
          blog.aliases = []
        end
      end
    end

    it 'does not generate alias resources when aliases array is empty' do
      alias_resources = app_no_aliases.sitemap.resources.select { |r| r.metadata&.dig(:locals, 'page_type') == 'alias' }
      expect(alias_resources).to be_empty
    end
  end
end