# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

FROM oeru/wenotes-base

MAINTAINER Dave Lane dave@oerfoundation.org
# (adapted from work by Clemens Stolle klaemo@apache.org)

# set up the various scripts we need to run on the container
# after it's built...
COPY ./conf /root/conf/
#Prepare the main install script
RUN chmod u+x /root/conf/*.sh

# expose relevant volumes
VOLUME ["/opt/wenotes/tools", "/opt/wenotes/logs", "/opt/wenotes/tools/options.json", "/opt/wenotes/tools/msmtprc"]

# First, say we're doing it
RUN echo "running run.sh - /root/conf/run.sh"
# Actually do it when we run the container.
#ENTRYPOINT ["tini", "--", "/root/conf/*.sh"]
CMD /root/conf/run.sh && bash
