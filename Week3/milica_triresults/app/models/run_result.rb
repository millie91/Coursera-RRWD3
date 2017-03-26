class RunResult <  LegResult

include Mongoid::Document
field :mmile,  as: :minute_mile, type: Float

def calc_ave
if event && secs
self[:mmile]=(secs/60)/self.event.miles
end
end
end


