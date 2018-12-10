# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2018 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/base_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/to_b'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Introscope support.
    class PinpointAgent < JavaBuildpack::Component::VersionedDependencyComponent

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
	FileUtils.mkdir_p logs_dir
        download_jar
	@droplet.copy_resources
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        java_opts   = @droplet.java_opts
        java_opts
          .add_javaagent(agent_jar)      
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        @application.services.one_service? FILTER, %w[agent_manager_url url]
      end

      private

      FILTER = /pinpoint/

      private_constant :FILTER

      def agent_host_name
        @application.details['application_name']
      end

      def agent_jar
        @droplet.sandbox + 'pinpoint-agent-1.8.0.jar'
      end
	    
      def logs_dir
    	@droplet.sandbox + 'logs'
      end

        # @macro base_component_release
      def release
       @droplet.java_opts
        .add_javaagent(@droplet.sandbox + jar_name)
        .add_system_property('pinpoint.agentId', "'#{agent_id}'")       
        .add_system_property('pinpoint.applicationName.', "'#{application_name}'")
        .add_system_property('pinpoint.config.log_file_path', logs_dir)
  end
	  
      def pinpointconf
        @droplet.sandbox + 'pinpoint.config'
      end
	  


  
      def agent_profile
        @droplet.sandbox + 'pinpoint.config'
      end

      def default_process_name(credentials)
        credentials['agent_default_process_name'] || @application.details['application_name']
      end

      
      
      
    end
  end
end
