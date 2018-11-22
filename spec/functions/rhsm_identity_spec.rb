#!/usr/bin/ruby -S rspec
# frozen_string_literal: true

#
#  Test the rhsm_identity fact
#
#   Copyright 2016 WaveClaw <waveclaw@hotmail.com>
#
#   See LICENSE for licensing.
#

require 'spec_helper'
require 'facter/rhsm_identity'

expected_data = '12345678-1234-1234-1234-0123456789ab'

raw_data1 = <<EOD
junk
Current identity is: 12345678-1234-1234-1234-0123456789ab
junk
EOD

raw_data2 = <<EOD
system identity: 12345678-1234-1234-1234-0123456789ab
name: abcd
org name: DEV
org ID: default-org
environment name: Library
EOD

describe Facter::Util::Rhsm_identity, type: :fact do
  before :each do
    Facter::Util::Loader.stubs(:load_all)
    Facter.clear
    Facter.clear_messages
  end
  it 'returns the expected data for old style return' do
    expect(Facter::Util::Resolution).to receive(:exec)
      .with('/usr/sbin/subscription-manager identity').and_return(raw_data1)
    expect(Facter::Util::Rhsm_identity.rhsm_identity).to eq(expected_data)
  end
  it 'returns the expected data for new style' do
    expect(Facter::Util::Resolution).to receive(:exec)
      .with('/usr/sbin/subscription-manager identity').and_return(raw_data2)
    expect(Facter::Util::Rhsm_identity.rhsm_identity).to eq(expected_data)
  end
  it 'returns the nothing for no data' do
    expect(Facter::Util::Resolution).to receive(:exec)
      .with('/usr/sbin/subscription-manager identity').and_return('')
    expect(Facter::Util::Rhsm_identity.rhsm_identity).to eq(nil)
  end
  it 'returns the nothing for no command' do
    expect(Facter::Util::Resolution).to receive(:exec)
      .with('/usr/sbin/subscription-manager identity').and_return(nil)
    expect(Facter::Util::Rhsm_identity.rhsm_identity).to eq(nil)
  end
  it 'returns the nothing for an error' do
    expect(Facter::Util::Resolution).to receive(:exec)
      .with('/usr/sbin/subscription-manager identity') { throw Error }
    expect(Facter).to receive(:debug)
    expect(Facter::Util::Rhsm_identity.rhsm_identity).to eq(nil)
  end
end
