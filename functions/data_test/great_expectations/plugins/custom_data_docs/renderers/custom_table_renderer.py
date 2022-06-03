import datetime
import json
import logging

from great_expectations.render.types import (
    RenderedBootstrapTableContent,
    RenderedDocumentContent,
    RenderedHeaderContent,
    RenderedSectionContent,
    RenderedStringTemplateContent,
    RenderedTabsContent,
)

from great_expectations.render.renderer import SiteIndexPageRenderer

logger = logging.getLogger(__name__)


# FIXME : This class needs to be rebuilt to accept SiteSectionIdentifiers as input.
# FIXME : This class needs tests.

class CustomTableRenderer(SiteIndexPageRenderer):
    # TODO: deprecate dual batch api support in 0.14
    @classmethod
    def _generate_validation_results_link_table(cls, index_links_dict):


        table_options = {
            "search": "true",
            "trimOnSearch": "false",
            "visibleSearch": "true",
            "rowStyle": "rowStyleLinks",
            "rowAttributes": "rowAttributesLinks",
            "sortName": "run_time",
            "sortOrder": "desc",
            "pagination": "true",
            "filterControl": "true",
            "iconSize": "sm",
            "toolbarAlign": "right",
        }

        table_columns = [
            {
                "field": "validation_success",
                "title": "Status",
                "sortable": "true",
                "align": "center",
                "filterControl": "select",
                "filterDataCollector": "validationSuccessFilterDataCollector",
            },
            {
                "field": "run_time",
                "title": "Run Time",
                "sortName": "_run_time_sort",
                "sortable": "true",
                "filterControl": "datepicker",
            },
            {
                "field": "asset_name",
                "title": "Asset Name",
                "sortable": "true",
                "filterControl": "select",
            },
            {
                "field": "batch_identifier",
                "title": "File_Name",
                "sortName": "_batch_identifier_sort",
                "sortable": "true",
                "filterControl": "input",
            },
            {
                "field": "expectation_suite_name",
                "title": "Expectation Suite",
                "sortName": "_expectation_suite_name_sort",
                "sortable": "true",
                "filterControl": "select",
                "filterDataCollector": "expectationSuiteNameFilterDataCollector",
            }
            # {
            #     "field": "profiling_link",
            #     "title": "Profiling Link"
            # },
        ]
        validation_link_dicts = index_links_dict.get("validations_links", [])
        table_data = []
        i = 0

        for dict_ in validation_link_dicts:

            table_data.append(
                {
                    "validation_success": cls._render_validation_success_cell(
                        dict_.get("validation_success")
                    ),
                    "run_time": cls._get_formatted_datetime(dict_.get("run_time")),
                    "_run_time_sort": cls._get_timestamp(dict_.get("run_time")),
                    "batch_identifier": cls._render_batch_id_cell(
                        dict_.get("batch_identifier"),
                        dict_.get("batch_kwargs"),
                        dict_.get("batch_spec"),
                    ),
                    "_batch_identifier_sort": dict_.get("batch_identifier"),
                    "expectation_suite_name": cls._render_expectation_suite_cell(
                        dict_.get("expectation_suite_name"),
                        dict_.get("expectation_suite_filepath"),
                    ),
                    "_expectation_suite_name_sort": dict_.get("expectation_suite_name"),
                    # "profiling_link": cls._get_profiling_link(i, dict_.get("batch_kwargs")),
                    "_table_row_link_path": dict_.get("filepath"),
                    "_validation_success_text": "Success"
                    if dict_.get("validation_success")
                    else "Failed",
                    "asset_name": dict_.get("asset_name"),
                }
            )


        return RenderedBootstrapTableContent(
            **{
                "table_columns": table_columns,
                "table_data": table_data,
                "table_options": table_options,
                "styling": {
                    "classes": ["col-12", "ge-index-page-table-container"],
                    "body": {
                        "classes": [
                            "table-sm",
                            "ge-index-page-validation-results-table",
                        ]
                    },
                },
            }
        )

    # TODO: deprecate dual batch api support in 0.14
    @classmethod
    def _render_batch_id_cell(cls, batch_id, batch_kwargs=None, batch_spec=None):
        if batch_kwargs:
            content_title = "Batch Kwargs"
            content = json.dumps(batch_kwargs, indent=2)
        else:
            content_title = "Batch Spec"
            content = json.dumps(batch_spec, indent=2)
        return RenderedStringTemplateContent(
            **{
                "content_block_type": "string_template",
                "string_template": {
                    "template": str(eval(content)['path']),
                    # "tooltip": {
                    #     "content": f"{content_title}:\n\n{content}",
                    #     "placement": "top",
                    # },
                    "styling": {"classes": ["m-0", "p-0"]},
                },
            }
        )


    @classmethod
    def _get_profiling_link(cls,link_index, batch_kwargs=None):
        result = batch_kwargs['link'][-1-link_index]
        return RenderedStringTemplateContent(
            **{
                "content_block_type": "string_template",
                "string_template": {
                    "template": "$link_text",
                    "params": {"link_text": result},
                    "tag": "a",
                    "styling": {
                        "styles": {"word-break": "break-all"},
                        "attributes": {"href": result},
                        "classes": ["ge-index-page-table-expectation-suite-link"],
                    },
                },
            }
        )
