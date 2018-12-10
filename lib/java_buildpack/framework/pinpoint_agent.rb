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
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
require 'java_buildpack/util/qualify_path'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling zero-touch Dynatrace support.
    class PinpointAgent < JavaBuildpack::Component::VersionedDependencyComponent
      include JavaBuildpack::Util

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download(@version, @uri) { |file| expand file }
        @droplet.copy_resources
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        @droplet.java_opts.add_agentpath_with_props(agent_path, name: agent_name, server: server)
      end

      #protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      #def supports?
      #  (@application.services.one_service? FILTER, 'server') &&
      #  !(@application.services.one_service? FILTER, 'tenant') &&
      #  !(@application.services.one_service? FILTER, 'tenanttoken')
      #end

      private

      FILTER = /pinpoint/

      private_constant :FILTER

      def agent_dir
        @droplet.sandbox + 'agent'
      end

      def agent_path
        agent_dir + 'pinpoint-bootstrap-1.8.0.jar'
      end

      def agent_name
        @configuration['default_agent_name'] || "#{@application.details['application_name']}_#{profile_name}"
      end

      def expand(file)
        with_timing "Expanding Pinpoint agent to #{@droplet.sandbox.relative_path_from(@droplet.root)}" do
          Dir.mktmpdir do |root|
            root_path = Pathname.new(root)
            shell "unzip -qq #{file.path} -d #{root_path} 2>&1"
            unpack_agent root_path
          end
        end
      end

      

      def unpack_agent(root)
        FileUtils.mkdir_p(agent_dir)        
		FileUtils.mv(root + 'agent' +  'boot', agent_dir)
		FileUtils.mv(root + 'agent' + 'lib', agent_dir)
		FileUtils.mv(root + 'agent' +  'plugin', agent_dir)
		FileUtils.mv(root + 'agent' +  'script', agent_dir)
		FileUtils.mv(root + 'agent' + 'tools', agent_dir)
		FileUtils.mv(root + 'agent' + 'pinpoint.config', agent_dir)
        #FileUtils.mv(root + 'agent' + agent_unpack_path + lib_name, agent_dir)
      end

      
    end

  end
end
