begin
  require 'rubygems'
rescue LoadError
  puts "You must install rubygems to run this example"
  raise
end

begin
  require 'bundler/setup'
rescue LoadError
  puts "to set up this example, run these commands:"
  puts "  gem install bundler"
  puts "  bundle install"
  raise
end

require 'sinatra'
require 'dm-core'
require 'dm-migrations'

# Sinatra wants to set x-frame-options by default, disable it
disable :protection
# Enable sessions so we can remember the launch info between http requests, as
# the user takes the assessment
enable :sessions



# Handle POST requests to the endpoint "/lti_launch"
post "/lti_launch" do
  return "missing required values" unless params['launch_presentation_return_url']
  # NOTE: For this example I've pulled out the traditional LTI placement
  # "remembering" code to keep things clear. It should be easy to merge
  # this with the pervious examples for the best of both worlds :-).

  redirect to ("/youtube_search.html?return_url=" + params['launch_presentation_return_url'])
end

get "/config.xml" do
  headers 'Content-Type' => 'text/xml'
  <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0"
    xmlns:blti = "http://www.imsglobal.org/xsd/imsbasiclti_v1p0"
    xmlns:lticm ="http://www.imsglobal.org/xsd/imslticm_v1p0"
    xmlns:lticp ="http://www.imsglobal.org/xsd/imslticp_v1p0"
    xmlns:xsi = "http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation = "http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd
    http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd
    http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
    <blti:title>YouTube Lucky Searcher</blti:title>
    <blti:description>"I'm Feeling Lucky" for YouTube embedding</blti:description>
    <blti:icon>#{ request.scheme }://#{ request.host_with_port }/icon.png</blti:icon>
    <blti:extensions platform="canvas.instructure.com">
      <lticm:property name="tool_id">youtube_lti_better</lticm:property>
      <lticm:property name="privacy_level">anonymous</lticm:property>
      <lticm:options name="editor_button">
        <lticm:property name="url">#{ request.scheme }://#{ request.host_with_port }/lti_launch</lticm:property>
        <lticm:property name="text">YouTube Video</lticm:property>
        <lticm:property name="selection_width">450</lticm:property>
        <lticm:property name="selection_height">350</lticm:property>
        <lticm:property name="enabled">true</lticm:property>
      </lticm:options>
    </blti:extensions>
    <cartridge_bundle identifierref="BLTI001_Bundle"/>
    <cartridge_icon identifierref="BLTI001_Icon"/>
</cartridge_basiclti_link>  
  EOF
end

# NOTE: When we pull out the traditional LTI, a db isn't even needed anymore!