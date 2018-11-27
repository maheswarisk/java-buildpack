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

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/pinpoint_agent'

describe JavaBuildpack::Framework::PinpointAgent do
  include_context 'with component help'

  it 'does not detect if not enabled' do
    expect(component.detect).to be_nil
  end

  context do
    let(:configuration) { { 'enabled' => true } }

    it 'detects when enabled' do
      expect(component.detect).to eq("pinpoint-agent=#{version}")
    end

    it 'downloads Pinpoint agent',
       cache_fixture: 'stub-pinpoint-agent.tar.gz' do

      component.compile

      expect(sandbox + 'pinpoint-bootstrap-1.8.0.jar').to exist
    end

    context do
      it 'updates JAVA_OPTS' do
        component.release

        expect(java_opts).to include('-agentpath:$PWD/-agentpath:$PWD/.java-buildpack/pinpoint-agent/pinpoint-bootstrap-1.8.0.jar')

      end

      context do
        let(:configuration) { super().merge 'port' => 8_850 }

        it 'adds port from configuration to JAVA_OPTS if specified' do
          component.release

          expect(java_opts).to include('-agentpath:$PWD/.java-buildpack/pinpoint-agent/pinpoint-bootstrap-1.8.0.jar')
        end
      end

      context do
        let(:configuration) { super().merge 'nowait' => false }

        it 'disables nowait in JAVA_OPTS if specified' do
          component.release

          expect(java_opts).to include('-agentpath:$PWD-agentpath:$PWD/.java-buildpack/pinpoint-agent/pinpoint-bootstrap-1.8.0.jar')
        end
      end

    end

  end

end
