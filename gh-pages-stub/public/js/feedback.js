/*
 * Copyright 2014-2017 CyberVision, Inc.
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
FEEDBACK_RESULT_SELECTOR="#feedbackResult";
FEEDBACK_INPUT_FORM_SELECTOR='#feedbackAsk';
FEEDBACK_ANIMATION_TIME=500;
COOKIES_SELECTOR='jekver-feedback';
ACTIVE_FEEDBACK_TYPE_SELECTOR='#feedbackAsk .btn.btn-primary.active > input';
FEEDBACK_EMAIL_SELECTOR='#feedbackEmail1';
FEEDBACK_TEXT_SELECTOR='#feedbackTextarea';
FEEDBACK_NAME_SELECTOR='#feedbackName'
FEEDBACK_BTN_SELECTOR='#btnShowfeedbackForm';
SCROLL_ELEMENT_SELECTOR="div#main"
FEEDBACK_TIMEOUT_POPUP=10*1000;
FEEDBACK_FORM_SELECTOR='#feedbackForm'
FEEDBACK_POST_URL_SELECTOR='#feedbackPostUrl'

function setFeedbackCookie() {
  Cookies.set(COOKIES_SELECTOR, true,  { path: '/' });
}

function feedbackFromLoaded() {

  /*Setup validator*/
  $(FEEDBACK_FORM_SELECTOR).validator("update");

  /* Setup submit callback */
  $(FEEDBACK_FORM_SELECTOR).validator().on('submit', function (e) {
    if (e.isDefaultPrevented()) {
      // handle the invalid form...
    } else {
      /* Check cache and show feedback field if necessary */
      var TITLE=document.title;
      var VERSION = UTILS.getVersionFromURL();
      var FEEDBACK_TYPE = $(ACTIVE_FEEDBACK_TYPE_SELECTOR)[0].id;
      var FEEDBACK_EMAIL = $(FEEDBACK_EMAIL_SELECTOR)[0].value;
      var FEEDBACK_TEXT = $(FEEDBACK_TEXT_SELECTOR)[0].value;
      var FEEDBACK_NAME = $(FEEDBACK_NAME_SELECTOR)[0].value;

      /* Send feedback to google analytics */
      Analytic.getInstance().sendFeedback(FEEDBACK_TYPE,VERSION,TITLE, FEEDBACK_NAME, FEEDBACK_EMAIL,FEEDBACK_TEXT);
      setFeedbackCookie();
      $(FEEDBACK_INPUT_FORM_SELECTOR).hide(FEEDBACK_ANIMATION_TIME);
      $(FEEDBACK_RESULT_SELECTOR).show(FEEDBACK_ANIMATION_TIME);

      /* Post feedback somewhere */
      var ACTION_URL = $(FEEDBACK_POST_URL_SELECTOR)[0].value;
      if (!UTILS.isBlank(ACTION_URL)) {
        $.post(ACTION_URL,
                {
                  "email": FEEDBACK_EMAIL,
                  "name": FEEDBACK_NAME,
                  "doc_page": TITLE,
                  "doc_version": VERSION,
                  "feedback": FEEDBACK_TEXT,
                  "lead_source_description": 'Documentation'
                });
      }
    }
    return false;
  })
}

$(document).ready(function(){

  /* Enable popovers with html */
  $("[data-toggle=popover]").popover({html : true});

  /* Setup popover close button functionality */
  $(document).on("click", ".popover .feedback-close" , function(){
      $(this).parents(".popover").prev().trigger('click');
  });

  /* Check the cookies . If there is no feedback for this page */
  if (!Cookies.get(COOKIES_SELECTOR)) {

    /* Setup Timeout feedback */
    window.setTimeout(function() {
        $(FEEDBACK_BTN_SELECTOR).trigger('click');

        setFeedbackCookie();
    }, FEEDBACK_TIMEOUT_POPUP);
  }
})
