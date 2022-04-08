# Main kickstart for Cinnamon.

%include fedora-live-cinnamon.ks
%include mixins/desktop-cinnamon.ks

# other supported languages
%include mixins/l10n/en_US-support.ks

# features
%include mixins/nonfree.ks
%include mixins/development.ks
