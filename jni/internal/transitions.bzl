# Copyright 2021 Fabian Meumertzheim
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

_COMMAND_LINE_OPTION_PLATFORMS = "//command_line_option:platforms"
_SETTING_PRE_TRANSITION_PLATFORMS = str(Label("//jni/internal:pre_transition_platforms"))

def _multi_platform_transition_impl(settings, attrs):
    if not attrs.platforms:
        return {
            _COMMAND_LINE_OPTION_PLATFORMS: settings[_COMMAND_LINE_OPTION_PLATFORMS],
            _SETTING_PRE_TRANSITION_PLATFORMS: settings[_SETTING_PRE_TRANSITION_PLATFORMS],
        }
    return [
        {
            _COMMAND_LINE_OPTION_PLATFORMS: [target_platform],
            _SETTING_PRE_TRANSITION_PLATFORMS: [str(label) for label in settings[_COMMAND_LINE_OPTION_PLATFORMS]],
        }
        for target_platform in attrs.platforms
    ]

multi_platform_transition = transition(
    implementation = _multi_platform_transition_impl,
    inputs = [
        _COMMAND_LINE_OPTION_PLATFORMS,
        _SETTING_PRE_TRANSITION_PLATFORMS,
    ],
    outputs = [
        _COMMAND_LINE_OPTION_PLATFORMS,
        _SETTING_PRE_TRANSITION_PLATFORMS,
    ],
)

def _return_to_original_target_platforms_transition(settings, attrs):
    if settings[_SETTING_PRE_TRANSITION_PLATFORMS]:
        result = {
            _SETTING_PRE_TRANSITION_PLATFORMS: [],
            _COMMAND_LINE_OPTION_PLATFORMS: settings[_SETTING_PRE_TRANSITION_PLATFORMS],
        }
    else:
        result = {
            _SETTING_PRE_TRANSITION_PLATFORMS: settings[_SETTING_PRE_TRANSITION_PLATFORMS],
            _COMMAND_LINE_OPTION_PLATFORMS: settings[_COMMAND_LINE_OPTION_PLATFORMS],
        }
    return result

return_to_original_target_platforms_transition = transition(
    implementation = _return_to_original_target_platforms_transition,
    inputs = [
        _COMMAND_LINE_OPTION_PLATFORMS,
        _SETTING_PRE_TRANSITION_PLATFORMS,
    ],
    outputs = [
        _COMMAND_LINE_OPTION_PLATFORMS,
        _SETTING_PRE_TRANSITION_PLATFORMS,
    ],
)
