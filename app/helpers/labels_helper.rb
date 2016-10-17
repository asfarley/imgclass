module LabelsHelper
    def safe_label_set label
        label.label_set.try(:id) || "<span class='text-danger'>invalid set</span>".html_safe
    end
end
