require 'spec_helper'

describe Bill do
  describe 'long_type_to_short' do
    it "shortens known bill types" do
      Bill.long_type_to_short("H. Res.").should == 'hr'
    end

    it "returns nil for unknown bill types" do
      Bill.long_type_to_short("Fake Bill Type").should be_nil
    end
  end
end

